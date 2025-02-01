//
//  ChatViewModel.swift
//  LeagueOfGents
//
//  Created by mark Slater on 1/30/25.
//
import SwiftUI
import Firebase
import FirebaseFirestore

struct Message: Identifiable {
    var id = UUID()
    var text: String
    var isUser: Bool
}
import Firebase
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    private let db = Firestore.firestore()
    private let openAIEndpoint = "https://api.openai.com/v1/chat/completions"
    private let openAIKey = "YOUR_OPENAI_API_KEY" // Replace with your OpenAI API Key
    private let imageArray = ["image1", "image2", "image3", "image4", "image5"]
    
    init() {
        fetchStoredKnowledge()
    }
    
    func fetchStoredKnowledge() {
        db.collection("knowledge_base").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching knowledge: \(error.localizedDescription)")
                return
            }
            
            let storedMessages = snapshot?.documents.compactMap { doc in
                Message(text: doc["text"] as? String ?? "", isUser: false)
            } ?? []
            
            DispatchQueue.main.async {
                self.messages.append(contentsOf: storedMessages)
            }
        }
    }
    
    func sendMessage(_ text: String) {
        let userMessage = Message(text: text, isUser: true)
        messages.append(userMessage)
        
        queryOpenAI(prompt: text) { response in
            DispatchQueue.main.async {
                self.messages.append(Message(text: response, isUser: false))
            }
        }
    }
    
    private func queryOpenAI(prompt: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: openAIEndpoint) else { return }
        
        let body: [String: Any] = [
            "model": "gpt-4",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 100
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil,
                  let response = try? JSONDecoder().decode(OpenAIResponse.self, from: data) else {
                completion("Error fetching response")
                return
            }
            completion(response.choices.first?.message.content ?? "No response")
        }.resume()
    }
}

struct LaunchScreenView: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .edgesIgnoringSafeArea(.all)
    }
}

@main
struct League_Of_GentlemenApp: App {
    @State private var isActive = false
    private let imageArray = ["image1", "image2", "image3", "image4", "image5"]
    private let selectedImage: String

    init() {
        selectedImage = imageArray.randomElement() ?? "defaultImage"
    }
    
    var body: some Scene {
        WindowGroup {
            if isActive {
                ContentView()
            } else {
                LaunchScreenView(imageName: selectedImage)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isActive = true
                        }
                    }
            }
        }
    }
}
