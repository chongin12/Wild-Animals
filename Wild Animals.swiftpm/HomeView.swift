import SwiftUI
import MapKit
import SwiftData

extension PresentationDetent {
    static var animalSmall = Self.fraction(0.1)
    static var animalMedium = Self.fraction(0.3)
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

    @State private var selection: String?

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

                AnimalAddView()
                    .padding(4)
                    .padding(.top, 2)
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
        .onChange(of: locationDataManager.currentCoordinator, { // 이거 없으면 작동 안함 주의!!
            print("currentCoordinator : \(locationDataManager.currentCoordinator)")
        })
        .onChange(of: selection) {
            withAnimation(.smooth(duration: 3.5)) {
                if let location: CLLocationCoordinate2D = self.animals.filter({ $0.id == selection }).first?.location {
                    let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
                    position = .region(region)
                }
            }
        }
        .onAppear {
            self.selection = nil
//            addMockData()
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
                    .frame(minWidth: 40, minHeight: 40)
                    .scaleEffect(1.5)
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

    @State private var isAddingAnimal: Bool = false

    @ViewBuilder
    private func AnimalAddView() -> some View {
        VStack(alignment: .leading) {
            if isAddingAnimal {
                HStack {
                    Button(action: {
                        isAddingAnimal.toggle()
                    }, label: {
                        Image(systemName: "x.square.fill")
                            .resizable()
                            .frame(maxWidth: 42, maxHeight: 42)
                    })
                    .tint(.red)
                    Button(action: {
                        isAddingAnimal.toggle()
                    }, label: {
                        Image(systemName: "checkmark.square.fill")
                            .resizable()
                            .frame(maxWidth: 42, maxHeight: 42)
                    })
                    .tint(.green)
                }

            } else {
                Button(action: {
                    isAddingAnimal.toggle()
                }, label: {
                    Image(systemName: "plus.square.fill")
                        .resizable()
                        .frame(maxWidth: 42, maxHeight: 42)
                })
                .tint(.black)
            }
        }
        .animation(.bouncy, value: isAddingAnimal)
        .transition(.identity)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .shadow(radius: 4)
    }
}

extension MKCoordinateRegion {
    func toCameraPosition() -> MapCameraPosition {
        return .region(self)
    }
}

extension CLLocationCoordinate2D {
//    static let C5 = Self(latitude: 36.01407851917902, longitude: 129.32582384219566)
    static var cat = Self(latitude: 36.014423345211746, longitude: 129.32558167819457)
    static var dog = Self(latitude: 36.01447215110666, longitude: 129.32503969659575)
    static var tiger = Self(latitude: 36.017610689980785, longitude: 129.3220931144489)
    static var panda = Self(latitude: 36.014086474244166, longitude: 129.32634253673842)
    static var rabbit = Self(latitude: 36.01378138419845, longitude: 129.32627811663477)
    static var hamster = Self(latitude: 36.01407851917902, longitude: 129.32582384219566)
}
