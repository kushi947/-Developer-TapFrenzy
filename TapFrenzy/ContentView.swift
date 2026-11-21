
import SwiftUI
import Combine
import AVFoundation

enum GamePhase {
    case idle
    case playing
    case over
}

struct ContentView: View {

    // Game Variables

    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var phase: GamePhase = .idle

    @State private var buttonScale: CGFloat = 1.0

    // Saved Data

    @AppStorage("highScore")
    private var highScore = 0

    @AppStorage("tapFrenzySoundEnabled")
    private var soundEnabled = true

    // Audio Players

    @State private var tapPlayer: AVAudioPlayer?
    @State private var startPlayer: AVAudioPlayer?
    @State private var gameOverPlayer: AVAudioPlayer?

    // Timer

    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {

        ZStack {

            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.08, blue: 0.12),
                    Color(red: 0.02, green: 0.02, blue: 0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 25) {

                // Header

                HStack {

                    VStack(alignment: .leading, spacing: 5) {

                        Text("TAP FRENZY")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)

                        Text("TEST YOUR SPEED!")
                            .font(.caption)
                            .tracking(2)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // Sound toggle
                    Button {

                        soundEnabled.toggle()

                    } label: {

                        Image(
                            systemName: soundEnabled
                            ? "speaker.wave.2.fill"
                            : "speaker.slash.fill"
                        )
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                    }
                }

                // Score

                VStack(spacing: 5) {

                    Text("YOUR SCORE")
                        .font(.caption)
                        .tracking(2)
                        .foregroundColor(.gray)

                    Text("\(score)")
                        .font(.system(size: 65, weight: .heavy))
                        .foregroundColor(.green)
                        .contentTransition(.numericText())
                }

                // Timer

                VStack(spacing: 10) {

                    HStack {

                        Text("TIME LEFT")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Spacer()

                        Text("\(timeRemaining) SEC")
                            .font(.headline)
                            .foregroundColor(
                                timeRemaining <= 3
                                ? .red
                                : .white
                            )
                    }

                    ProgressView(
                        value: Double(timeRemaining),
                        total: 10
                    )
                    .tint(timeRemaining <= 3 ? .red : .green)
                    .scaleEffect(y: 2)
                }

                // Game Button

                Spacer()

                if phase != .over {

                    Button {

                        tapButton()

                    } label: {

                        ZStack {

                            Circle()
                                .fill(Color.green.opacity(0.15))
                                .frame(width: 235, height: 235)

                            Circle()
                                .fill(Color.green.opacity(0.3))
                                .frame(width: 210, height: 210)

                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.green,
                                            Color(red: 0.0, green: 0.65, blue: 0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 180, height: 180)

                            VStack(spacing: 8) {

                                Image(systemName: "hand.tap.fill")
                                    .font(.system(size: 40))

                                Text(
                                    phase == .idle
                                    ? "START"
                                    : "TAP!"
                                )
                                .font(.title)
                                .fontWeight(.heavy)
                            }
                            .foregroundColor(.white)
                        }
                        .scaleEffect(buttonScale)
                    }
                    .buttonStyle(.plain)
                    .disabled(phase == .idle && false)

                } else {

                    // Game Over

                    VStack(spacing: 15) {

                        Image(systemName: "trophy.fill")
                            .font(.system(size: 55))
                            .foregroundColor(.yellow)

                        Text("GAME OVER!")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)

                        Text("YOUR SCORE: \(score)")
                            .font(.title2)
                            .foregroundColor(.green)

                        Text("BEST SCORE: \(highScore)")
                            .font(.headline)
                            .foregroundColor(.yellow)

                        Button {

                            resetGame()

                        } label: {

                            Label(
                                "PLAY AGAIN",
                                systemImage: "arrow.clockwise"
                            )
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(15)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.07))
                    .cornerRadius(20)
                }

                Spacer()

                // High Score

                VStack(spacing: 5) {

                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)

                    Text("PERSONAL BEST")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("\(highScore)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }

                Spacer()
            }
            .padding(25)
        }
        .onAppear {
            prepareAudio()
        }
        .onReceive(timer) { _ in
            updateTimer()
        }
        .animation(.easeInOut, value: timeRemaining)
        .animation(.spring(), value: score)
    }

    // Prepare Sound

    func prepareAudio() {

        tapPlayer = loadSound(
            name: "tap"
        )

        startPlayer = loadSound(
            name: "start"
        )

        gameOverPlayer = loadSound(
            name: "gameover"
        )
    }

    func loadSound(name: String) -> AVAudioPlayer? {

        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: "wav"
        ) else {

            print("Sound file not found: \(name).wav")
            return nil
        }

        do {

            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            return player

        } catch {

            print("Audio error: \(error)")
            return nil
        }
    }

    // Play Sound

    func playSound(_ player: AVAudioPlayer?) {

        guard soundEnabled else {
            return
        }

        player?.currentTime = 0
        player?.play()
    }

    // Handle Taps

    func tapButton() {

        if phase == .idle {

            startGame()
            return
        }

        guard phase == .playing else {
            return
        }

        score += 1

        playSound(tapPlayer)

        if score > highScore {
            highScore = score
        }

        // Button animation
        withAnimation(.spring(
            response: 0.2,
            dampingFraction: 0.4
        )) {

            buttonScale = 0.92
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.12
        ) {

            withAnimation {
                buttonScale = 1.0
            }
        }
    }

    // Start Game

    func startGame() {

        score = 0
        timeRemaining = 10
        phase = .playing

        playSound(startPlayer)
    }

    // Update Timer

    func updateTimer() {

        guard phase == .playing else {
            return
        }

        if timeRemaining > 1 {

            timeRemaining -= 1

        } else {

            timeRemaining = 0
            phase = .over

            if score > highScore {
                highScore = score
            }

            playSound(gameOverPlayer)
        }
    }

    // Restart Game

    func resetGame() {

        score = 0
        timeRemaining = 10
        buttonScale = 1.0
        phase = .idle
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}

