//
///
import SwiftUI
import Combine

enum GamePhase {
    case idle
    case playing
    case over
}

struct ContentView: View {

    // Step 3: Score
    @State private var score = 0

    // Step 4: Countdown timer
    @State private var timeRemaining = 10

    // Step 5: Game phases
    @State private var phase: GamePhase = .idle

    // Step 6: Save high score
    @AppStorage("highScore") private var highScore = 0

    // Timer publisher
    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {

        VStack(spacing: 25) {

            // Game title
            Text("Tap Frenzy")
                .font(.largeTitle)
                .fontWeight(.heavy)

            // Score
            VStack(spacing: 5) {
                Text("SCORE")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("\(score)")
                    .font(.system(size: 65, weight: .heavy))
                    .foregroundColor(.green)
            }

            // Timer
            VStack(spacing: 5) {
                Text("TIME REMAINING")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("\(timeRemaining) seconds")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(timeRemaining <= 3 ? .red : .primary)
            }

            // Game button
            if phase != .over {

                Button(action: tapButton) {

                    Text(phase == .idle ? "TAP TO START" : "TAP")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                        .frame(width: 200, height: 200)
                        .background(Color.green)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

            } else {

                VStack(spacing: 15) {

                    Text("GAME OVER!")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(.red)

                    Text("Your Score: \(score)")
                        .font(.title2)

                    Button("PLAY AGAIN") {
                        resetGame()
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                }
            }

            // High score
            VStack(spacing: 5) {
                Text("BEST SCORE")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("\(highScore)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }

            Spacer()
        }
        .padding()
        .onReceive(timer) { _ in
            updateTimer()
        }
    }

    // Handle button taps
    func tapButton() {

        if phase == .idle {
            phase = .playing
        }

        if phase == .playing {
            score += 1
        }
    }

    // Countdown timer
    func updateTimer() {

        guard phase == .playing else {
            return
        }

        if timeRemaining > 1 {
            timeRemaining -= 1
        } else {
            timeRemaining = 0
            phase = .over

            // Update high score
            if score > highScore {
                highScore = score
            }
        }
    }

    // Restart game
    func resetGame() {

        score = 0
        timeRemaining = 10
        phase = .idle
    }
}

#Preview {
    ContentView()
}

