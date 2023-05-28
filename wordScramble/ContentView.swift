//
//  ContentView.swift
//  wordScramble
//
//  Created by George on 5/18/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootword = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView{
            List{
                Section{
                    TextField("Enter your word", text: $newWord).autocapitalization(.none)
                }
                
                Section{
                    ForEach(usedWords, id: \.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        
                    }
                }
            }
            .navigationTitle(rootword)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame) // calls a function when the view is shown. In this case it quickly calls startGame
            .alert(errorTitle, isPresented: $showingError){
                Button("Ok", role: .cancel){}
            }message:{
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {return} // Checks for at least one char
        
        guard isOriginal(word: answer) else{
            wordError(title: "Word already used", message: "Please select another!")
            return
        }
        
        guard isPossible(word: answer) else{
            wordError(title: "Word not possible", message: "That word cannot be spelled from \(rootword)!")
            return
        }
        
        guard isReal(word: answer) else{
            wordError(title: "Word not recognized", message: "The word is either misspelled or made up !")
            return
        }
        
        
        
        withAnimation{
            usedWords.insert(answer, at: 0) // start of the array
        }
        newWord = ""
    }
    
    func startGame(){
        //Attempt to find the URL with filename start.txt
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt"){
            //tries to read the contents of the file
            if let startWords = try? String(contentsOf: startWordsUrl){
                //splits the contents of the file into an array of strings
                let allWords = startWords.components(separatedBy: "\n")
                
                //picks a random word from the array allwords. If it somehow can't find a word, then it will just pick silkworm
                rootword = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load file")
        
    }
    
    func isOriginal(word: String)->Bool{
        !usedWords.contains(word)
    }
    
    //Checks if it is possible to form a given 'word' using the characters from rootword
    func isPossible(word: String)-> Bool{
        var tempWord = rootword
        
        for letter in word {
            // Checks if the letters in word are in tempWord. If it is then remove the letter, else return false
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else{
                return false
            }
        }
        return true
    }
    
    func isReal(word: String)->Bool{
        let checker = UITextChecker()// class i IOS used to check grammar and spelling
        let range = NSRange(location: 0, length: word.utf16.count) // range of the word
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en") // checks is the word is misspelled
        
        return misspelledRange.location == NSNotFound // returns true if no misspelled words were found
    }
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
