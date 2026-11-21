
import SwiftUI

struct HomeView: View {

    // Saved High Scores

    @AppStorage("highScore")
    private var tapFrenzyHighScore = 0

    @AppStorage("lightItUpHighScore")
    private var lightItUpHighScore = 0

    // Instructions popup
    @State private var showInstructions = false

    var body: some View {

        NavigationStack {

            ZStack {

                // Background

                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.06, blue: 0.15),
                        Color(red: 0.10, green: 0.08, blue: 0.22),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Main Content

                ScrollView {

                    VStack(spacing: 30) {

                        // Header
                        VStack(spacing: 12) {

                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 55))
                                .foregroundStyle(.yellow)

                            Text("LIGHT IT UP")
                                .font(.system(size: 34, weight: .heavy))
                                .foregroundColor(.white)

                            Text("WELCOME TO THE ARCADE")
                                .font(.caption)
                                .fontWeight(.medium)
                                .tracking(3)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 35)

                        // Instructions button
                        Button {
                            showInstructions = true
                        } label: {

                            Label(
                                "How to Play",
                                systemImage: "questionmark.circle"
                            )
                            .font(.subheadline)
                            .foregroundColor(.white)
                        }

                        // Game cards
                        VStack(spacing: 20) {

                            // Game 1
                            NavigationLink {
                                ContentView()
                            } label: {

                                gameCard(
                                    number: "GAME 01",
                                    title: "TAP FRENZY",
                                    description: "Tap as fast as you can in 10 seconds!",
                                    icon: "bolt.fill",
                                    color: .green,
                                    highScore: tapFrenzyHighScore
                                )
                            }

                            // Game 2
                            NavigationLink {
                                LightItUpView()
                            } label: {

                                gameCard(
                                    number: "GAME 02",
                                    title: "LIGHT IT UP",
                                    description: "Find and tap the glowing cards!",
                                    icon: "lightbulb.fill",
                                    color: .orange,
                                    highScore: lightItUpHighScore
                                )
                            }
                        }

                        // Footer
                        VStack(spacing: 8) {

                            Text("CHOOSE YOUR CHALLENGE")
                                .font(.caption)
                                .tracking(2)
                                .foregroundColor(.gray)

                            Text("TUTORIAL 2")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 25)
                    }
                    .padding(.horizontal, 22)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .alert(
                "How to Play",
                isPresented: $showInstructions
            ) {

                Button("Got it", role: .cancel) { }

            } message: {

                Text("""
                TAP FRENZY:
                Tap the green button as many times as possible before time runs out.

                LIGHT IT UP:
                Find the glowing yellow card and tap it to earn points.
                """)
            }
        }
    }

    // Reusable Game Card

    func gameCard(
        number: String,
        title: String,
        description: String,
        icon: String,
        color: Color,
        highScore: Int
    ) -> some View {

        HStack(spacing: 16) {

            // Game icon
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
                .frame(width: 65, height: 65)
                .background(color.opacity(0.15))
                .cornerRadius(15)

            // Game information
            VStack(alignment: .leading, spacing: 8) {

                Text(number)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .tracking(2)
                    .foregroundColor(color)

                Text(title)
                    .font(.headline)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)

                Text("BEST SCORE: \(highScore)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                    .padding(.top, 5)
            }

            Spacer(minLength: 0)

            // Navigation arrow
            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(color.opacity(0.35), lineWidth: 1)
        )
    }
}

#Preview {
    HomeView()
}

