
import SwiftUI
import Combine
import AVFoundation

struct LightItUpView: View {

    // Game Variables

    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var lives = 3

    @State private var activeCard = -1
    @State private var gameStarted = false
    @State private var gameOver = false

    @State private var cardTimeRemaining: Double = 1.5
    @State private var cardScale: CGFloat = 1.0

    // Saved Data

    @AppStorage("lightItUpHighScore")
    private var highScore = 0

    @AppStorage("lightItUpSoundEnabled")
    private var soundEnabled = true

    // Audio Players

    @State private var startPlayer: AVAudioPlayer?
    @State private var correctPlayer: AVAudioPlayer?
    @State private var wrongPlayer: AVAudioPlayer?
    @State private var missedPlayer: AVAudioPlayer?
    @State private var gameOverPlayer: AVAudioPlayer?

    // Grid

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    // Timers

    private let gameTimer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    private let reactionTimer = Timer.publish(
        every: 0.05,
        on: .main,
        in: .common
    ).autoconnect()

    // Level

    var level: Int {
        (score / 5) + 1
    }

    // Card Duration

    var cardDuration: Double {
        max(0.55, 1.5 - Double(level - 1) * 0.15)
    }

    var body: some View {

        ZStack {

            // Background

            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.06, blue: 0.16),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {

                // Header

                HStack {

                    VStack(alignment: .leading, spacing: 5) {

                        Text("LIGHT IT UP")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)

                        Text("TEST YOUR REACTION!")
                            .font(.caption)
                            .tracking(2)
                            .foregroundColor(.gray)
                    }

                    Spacer()

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

                // Score and Time

                HStack(spacing: 15) {

                    statCard(
                        title: "SCORE",
                        value: "\(score)",
                        color: .green
                    )

                    statCard(
                        title: "TIME",
                        value: "\(timeRemaining)s",
                        color: .orange
                    )

                    statCard(
                        title: "LEVEL",
                        value: "\(level)",
                        color: .purple
                    )
                }

                // MARK: - Lives

                HStack {

                    Text("LIVES")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Spacer()

                    ForEach(0..<3, id: \.self) { index in

                        Image(systemName: "heart.fill")
                            .foregroundColor(
                                index < lives ? .red : .gray.opacity(0.3)
                            )
                            .font(.title2)
                    }
                }

                // Reaction Progress

                VStack(alignment: .leading, spacing: 7) {

                    Text("REACTION TIME")
                        .font(.caption)
                        .foregroundColor(.gray)

                    ProgressView(
                        value: cardTimeRemaining,
                        total: max(cardDuration, 0.01)
                    )
                    .tint(.yellow)
                    .scaleEffect(y: 2)
                }

                // Game Grid

                LazyVGrid(columns: columns, spacing: 14) {

                    ForEach(0..<9, id: \.self) { index in

                        Button {

                            cardTapped(index)

                        } label: {

                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    activeCard == index
                                    ? Color.yellow
                                    : Color.white.opacity(0.08)
                                )
                                .frame(height: 95)
                                .overlay {

                                    Image(
                                        systemName: activeCard == index
                                        ? "lightbulb.fill"
                                        : "circle"
                                    )
                                    .font(.system(size: 32))
                                    .foregroundColor(
                                        activeCard == index
                                        ? .orange
                                        : .gray.opacity(0.4)
                                    )
                                }
                                .overlay {

                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(
                                            activeCard == index
                                            ? Color.yellow
                                            : Color.white.opacity(0.1),
                                            lineWidth: 2
                                        )
                                }
                                .scaleEffect(
                                    activeCard == index
                                    ? cardScale
                                    : 1.0
                                )
                                .shadow(
                                    color: activeCard == index
                                    ? .yellow.opacity(0.7)
                                    : .clear,
                                    radius: 15
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(!gameStarted)
                    }
                }

                // MARK: - Start Button

                if !gameStarted && !gameOver {

                    Button {

                        startGame()

                    } label: {

                        Label(
                            "START GAME",
                            systemImage: "play.fill"
                        )
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(15)
                    }
                }

                // Game Over

                if gameOver {

                    VStack(spacing: 12) {

                        Image(systemName: "trophy.fill")
                            .font(.system(size: 45))
                            .foregroundColor(.yellow)

                        Text("GAME OVER!")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)

                        Text("YOUR SCORE: \(score)")
                            .font(.title2)
                            .foregroundColor(.green)

                        Text("BEST SCORE: \(highScore)")
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
                            .background(Color.yellow)
                            .cornerRadius(15)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(20)
                }

                Spacer(minLength: 0)
            }
            .padding()
        }
        .onAppear {
            prepareAudio()
        }
        .onReceive(gameTimer) { _ in
            updateGameTimer()
        }
        .onReceive(reactionTimer) { _ in
            updateReactionTimer()
        }
        .animation(.spring(), value: score)
    }

    // Stat Card

    func statCard(
        title: String,
        value: String,
        color: Color
    ) -> some View {

        VStack(spacing: 7) {

            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)

            Text(value)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
        .background(Color.white.opacity(0.07))
        .cornerRadius(15)
    }

    // Prepare Audio

    func prepareAudio() {

        startPlayer = loadSound(name: "lightstart")
        correctPlayer = loadSound(name: "correct")
        wrongPlayer = loadSound(name: "wrong")
        missedPlayer = loadSound(name: "missed")
        gameOverPlayer = loadSound(name: "lightgameover")
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

    // Start Game

    func startGame() {

        score = 0
        lives = 3
        timeRemaining = 30

        gameOver = false
        gameStarted = true

        playSound(startPlayer)

        showRandomCard()
    }

    // Random Card

    func showRandomCard() {

        let previousCard = activeCard

        var newCard = Int.random(in: 0..<9)

        if previousCard >= 0 {

            while newCard == previousCard {
                newCard = Int.random(in: 0..<9)
            }
        }

        activeCard = newCard
        cardTimeRemaining = cardDuration

        withAnimation(.spring()) {
            cardScale = 1.08
        }
    }

    // Card Tapped

    func cardTapped(_ index: Int) {

        guard gameStarted && !gameOver else {
            return
        }

        if index == activeCard {

            // Correct tap

            score += 1

            playSound(correctPlayer)

            if score > highScore {
                highScore = score
            }

            showRandomCard()

        } else {

            // Wrong tap

            loseLife()
        }
    }

    // Lose Life

    func loseLife() {

        guard gameStarted else {
            return
        }

        lives -= 1

        playSound(wrongPlayer)

        if lives <= 0 {

            endGame()

        } else {

            showRandomCard()
        }
    }

    // Reaction Timer

    func updateReactionTimer() {

        guard gameStarted && !gameOver else {
            return
        }

        cardTimeRemaining -= 0.05

        if cardTimeRemaining <= 0 {

            // Player missed the glowing card

            lives -= 1

            playSound(missedPlayer)

            if lives <= 0 {

                endGame()

            } else {

                showRandomCard()
            }
        }
    }

    // Game Timer

    func updateGameTimer() {

        guard gameStarted && !gameOver else {
            return
        }

        if timeRemaining > 1 {

            timeRemaining -= 1

        } else {

            timeRemaining = 0
            endGame()
        }
    }

    // End Game

    func endGame() {

        gameStarted = false
        gameOver = true
        activeCard = -1

        cardTimeRemaining = 0

        if score > highScore {
            highScore = score
        }

        playSound(gameOverPlayer)
    }

    // Restart

    func resetGame() {

        score = 0
        lives = 3
        timeRemaining = 30

        activeCard = -1
        cardTimeRemaining = 1.5

        gameStarted = false
        gameOver = false

        cardScale = 1.0
    }
}

#Preview {
    NavigationStack {
        LightItUpView()
    }
}

