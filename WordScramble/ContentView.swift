//
//  ContentView.swift
//  WordScramble
//
//  Created by Khumbongmayum Tonny on 24/06/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords: [String] = []
    @State private var rootWord: String = ""
    @State private var newWord: String = ""
    
    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                ForEach(usedWords, id: \.self) {
                    Label("\($0)", systemImage: "\($0.count).circle")
                        .foregroundColor(.primary)
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                 Text(errorMessage)
            }
            .toolbar {
                Button("New Root word") {
                    startGame()
                }
            }
        }
        
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell from the '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognised", message: "You can't just make them up, you know!")
            return
        }
        
        guard isMoreThanTwoLetters(word: answer) else {
            wordError(title: "Word is less than 2 letters", message: "You can make it to more than two letters")
            return
        }
        
        guard isDifferentfromRootWord(word: answer) else {
            wordError(title: "Word is same as Root word", message: "Be more original!")
            return
        }
        
        withAnimation() {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Couldn't load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func isMoreThanTwoLetters(word: String) -> Bool {
        word.count > 2 ? true : false
    }
    
    func isDifferentfromRootWord(word: String) -> Bool {
        if rootWord.count == word.count {
            return !rootWord.contains(word)
        }
         return true
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
