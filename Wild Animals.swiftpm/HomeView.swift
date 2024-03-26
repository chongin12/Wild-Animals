import SwiftUI
import MapKit
import SwiftData
import PhotosUI

extension PresentationDetent {
    static var animalSmall = Self.fraction(0.15)
    static var animalMedium = Self.fraction(0.35)
}

struct HomeView: View {
    @Environment(LocationDataManager.self) private var locationDataManager
    @Environment(\.modelContext) private var modelContext
    @Query private var animals: [Animal]
    var currentAnimal: Animal? {
        self.animals.min { animal1, animal2 in
            LocationDataManager.shared.currentCoordinator.distance(from: animal1.location) < LocationDataManager.shared.currentCoordinator.distance(from: animal2.location)
        }
    }

    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @State private var isPresented: Bool = true

    @State private var detent: PresentationDetent = .animalSmall

    @State private var detentHeight: CGFloat = 0

    @State private var path: NavigationPath = .init()

    @State private var selection: String? // animal.id

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .topLeading) {
                Map(position: $position, selection: $selection) {
                    UserAnnotation()
                    ForEach(animals) { animal in
                        var distanceOfCurrent: Double {
                            self.locationDataManager.currentCoordinator.distance(from: animal.location)
                        }
                        AnimalAnnotation(animal)
                            .tag(animal.id)

                        MapCircle(center: animal.location, radius: AREA_RADIUS)
                            .foregroundStyle(distanceOfCurrent <= AREA_RADIUS ? .blue.opacity(0.15) : .orange.opacity(0.15))
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .mapControls {
                    MapUserLocationButton()
                }
                .navigationDestination(for: Animal.self) { animal in
                    let animalBinding: Binding<Animal> = Binding<Animal>(get: {
                        animals.filter { $0.id == animal.id }[0]
                    }, set: { animal in
                        modelContext.insert(animal)
                    })
                    DetailView(animal: animalBinding)
                }
                .sheet(isPresented: $isPresented) {
                    AnimalSummaryView()
                        .presentationDetents([.animalSmall, .animalMedium], selection: $detent)
                        .presentationDragIndicator(.visible)
                        .presentationBackgroundInteraction(.enabled(upThrough: .animalSmall))
                        .interactiveDismissDisabled(true)
                }

                VStack(spacing: 4) {
                    AddAnimalView()
                        .padding(4)
                        .padding(.top, 2)

                    if selection != nil && !isAddingAnimal {
                        DeleteAnimalView()
                            .padding(.horizontal, 4)
                    }
                }
            }
        }
        .animation(.easeInOut, value: detent)
        .animation(.bouncy, value: selection)
        .transition(.identity)
        .onChange(of: path.count, {
            print("path changed : \(path.count)")
            if path.count == 0 {
                withAnimation {
                    isPresented = true
                    detent = .animalSmall
                }
            }
        })
        .onChange(of: locationDataManager.currentCoordinator) { // 이거 없으면 작동 안함 주의!!
            print("currentCoordinator : \(locationDataManager.currentCoordinator)")
        }
        .onChange(of: selection) {
            withAnimation(.smooth(duration: 3.5)) {
                if let location: CLLocationCoordinate2D = self.animals.filter({ $0.id == selection }).first?.location {
                    let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
                    position = .region(region)
                }
            }
        }
        .onChange(of: isPhotosPickerPresenting) { oldValue, newValue in
            isPresented = !newValue
        }
        .onAppear {
            self.selection = nil
        }
        .photosPicker(isPresented: $isPhotosPickerPresenting, selection: $addImageSelection, matching: .images)
        .task(id: addImageSelection) {
            // UIImage로 받는 이유 : HIEC 이미지로 가져왔을 때 orientation에 문제가 생기기 때문.
            if let uiImage = try? await addImageSelection?.loadTransferable(type: UIImage.self)?.fixedOrientation {
                animalImage = uiImage
            }
        }
    }

    private func addMockData() {
        do {
            try modelContext.delete(model: Animal.self)
        } catch {
            print("Error! \(error.localizedDescription)")
        }
        [Animal].mockData.forEach { animal in
            modelContext.insert(animal)
        }
    }

    @ViewBuilder
    private func AnimalSummaryView() -> some View {
        GeometryReader { proxy in
            AnimalSummaryMediumView()
                .padding()
                .onAppear {
                    self.detentHeight = proxy.size.height
                }
                .onChange(of: proxy.size.height) {
                    self.detentHeight = proxy.size.height
                }
        }
    }

    @ViewBuilder
    private func AnimalSummaryMediumView() -> some View {
        VStack(alignment: .center) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("가장 가까운 동물")
                        .font(.body)
                    Text("\(currentAnimal?.name ?? "") 📍 \(Int(currentAnimal?.distance ?? 0))m")
                        .font(.title)
                }
                Spacer()
                Image(currentAnimal?.imageData ?? Data())
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 40, maxHeight: 40)
                    .scaleEffect(1.5)
                    .padding(.trailing)
            }
            HStack {
                AnimalSummaryAdditionView()
                    .opacity((detentHeight - 100) / 100.0)
            }
            .padding(.top, 8)
        }
    }

    @ViewBuilder
    private func AnimalSummaryAdditionView() -> some View {
        VStack(spacing: 16) {
            if let currentAnimal = currentAnimal {
                if currentAnimal.canTouch {
                    Text("주변에 있어요!")
                        .font(.title3)
                    Text("한번 만나볼까요?")
                    Button(action: {
                        withAnimation(.spring()) {
                            isPresented = false
                            path.append(currentAnimal)
                        }
                    }, label: {
                        Label("안녕? " + currentAnimal.name, systemImage: "hand.wave.fill")
                            .padding(6)
                    })
                    .buttonStyle(.borderedProminent)
                } else {
                    Text("아직 멀리 있어요.")
                        .font(.title3)
                    Text("조금 더 가까이 가보세요!")
                }
            } else {
                Text("아무 동물도 없네요..")
            }
        }
    }

    private func AnimalAnnotation(_ animal: Animal) -> some MapContent {
        Annotation(animal.name, coordinate: animal.location) {
            ZStack {
                Group {
                    Circle()
                        .fill(.background)
                    Circle()
                        .stroke(animal.canTouch ? .blue : .secondary, lineWidth: 4)
                    Image(animal.imageData)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .scaleEffect(1.5)
                        .clipShape(Circle())
                        .padding(5)
                }
                .offset(y: -42)
                .scaleEffect(selection == animal.id ? 1.5 : 1.0)
                .onTapGesture {
                    selection = animal.id
                }

                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 8, height: 8)
                    .padding()

                if selection == animal.id {
                    VStack(spacing: 8) {
                        Text(" \(animal.name) ")
                        Label("\(animal.food)", systemImage: "popcorn.fill")
                            .fontWeight(.light)
                        Label("\(animal.pat)", systemImage: "hand.wave.fill")
                            .fontWeight(.light)
                    }
                    .padding(8)
                    .frame(minWidth: 40)
                    .foregroundStyle(.white)
                    .background {
                        RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                            .fill(Color.gray.opacity(0.6))
                    }
                    .offset(y: 60)
                }
            }
            .frame(minWidth: 60, minHeight: 100, alignment: .bottom)
            .animation(.smooth(duration: 0.5), value: selection)
            .transition(.identity)
        }
        .annotationTitles(.hidden)
    }

    // MARK: - Adding Animal

    @State private var isAddingAnimal: Bool = false
    @State private var isPhotosPickerPresenting: Bool = false
    @State private var addImageSelection: PhotosPickerItem?
    @State private var animalImage: UIImage?
    @State private var animalName: String = ""

    @ViewBuilder
    private func AddAnimalView() -> some View {
        VStack(alignment: .center) {
            if isAddingAnimal {
                HStack {
                    Button(action: {
                        isAddingAnimal.toggle()
                        addImageSelection = nil
                        animalImage = nil
                    }, label: {
                        Image(systemName: "x.square.fill")
                            .resizable()
                            .frame(maxWidth: 42, maxHeight: 42)
                    })
                    .tint(.red)
                    Spacer()
                    Button(action: {
                        isAddingAnimal.toggle()
                        validate()
                    }, label: {
                        Image(systemName: "checkmark.square.fill")
                            .resizable()
                            .frame(maxWidth: 42, maxHeight: 42)
                    })
                    .tint(.green)
                }

                Spacer()

                ImagePickerView()
                    .padding()

                Spacer()

                TextField("이름", text: $animalName)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit {
                        validate()
                    }
                    .padding()
                    .textFieldStyle(.roundedBorder)

            } else {
                Button(action: {}, label: {
                    Image(systemName: "plus.square.fill")
                        .resizable()
                        .frame(maxWidth: 42, maxHeight: 42)
                        .onTapGesture { // action에 넣으면 long press gesture가 씹힘.
                            isAddingAnimal.toggle()
                        }
                        .onLongPressGesture {
                            addMockData()
                        }
                })
                .tint(.black)
            }
        }
        .frame(maxWidth: isAddingAnimal ? 150 : 42, maxHeight: isAddingAnimal ? 200 : 42)
        .animation(.bouncy, value: isAddingAnimal)
        .transition(.identity)
        .background(.background.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .shadow(radius: 4)
    }

    @ViewBuilder
    private func ImagePickerView() -> some View {
        Button {
            isPhotosPickerPresenting.toggle()
        } label: {
            if let animalImage {
                Image(uiImage: animalImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "photo.badge.plus")
                    .symbolRenderingMode(.palette)
                    .resizable()
                    .scaledToFit()
                    .buttonStyle(.borderedProminent)
            }
        }
    }

    private func validate() {
        if let imageData = animalImage?.jpegData(compressionQuality: 0.2), animalName != "" {
            let animal = Animal(
                name: animalName,
                imageData: imageData,
                location: LocationDataManager.shared.currentCoordinator
            )
            modelContext.insert(animal)
            self.selection = animal.id
            animalName = ""
            animalImage = nil
            isAddingAnimal = false
        }
    }

    // MARK: - Deleting Animal
    @ViewBuilder
    private func DeleteAnimalView() -> some View {
        Button(action: {
            if let selectedAnimal = animals.first(where: { $0.id == selection }) {
                modelContext.delete(selectedAnimal)
            }
            selection = nil
        }, label: {
            Image(systemName: "minus.square.fill")
                .resizable()
                .frame(maxWidth: 42, maxHeight: 42)
        })
        .tint(.red)
    }
}
