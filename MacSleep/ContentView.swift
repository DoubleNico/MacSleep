import SwiftUI

struct ContentView: View {
    @State private var seconds = 1
    @State private var minutes = 0
    @State private var hours = 0
    @State private var type: String = "List"
    @State private var inputHours = ""
    @State private var inputMinutes = ""
    @State private var inputSeconds = ""
    @State private var timerWorkItem: DispatchWorkItem?
    @State private var remainingTime = 0
    @State private var countdownTimer: Timer?

    var totalSeconds: Int {
        return hours * 3600 + minutes * 60 + seconds
    }

    var formattedTime: String {
        let hoursString = String(format: "%02d", hours)
        let minutesString = String(format: "%02d", minutes)
        let secondsString = String(format: "%02d", remainingTime)
        return "\(hoursString):\(minutesString):\(secondsString)"
    }

    var body: some View {
        VStack(alignment: .center) {
            Text("MacSleep")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .accessibilityLabel("Title")
            Picker("Select", selection: $type){
                Text("List").tag("List")
                Text("Input").tag("Input")
            }.pickerStyle(.segmented)
                
            if (type == "List"){
                List {
                    Text("Setting timer for \(hours) hours, \(minutes) minutes, \(seconds) seconds")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    Picker("Hours", selection: $hours){
                        ForEach(0..<24) { hour in
                            Text("\(hour)").tag(hour)
                        }
                    }
                    .padding(.trailing, 250.0)
                    Picker("Minutes", selection: $minutes){
                        ForEach(0..<60) { minute in
                            Text("\(minute)").tag(minute)
                        }
                    }
                    .padding(.trailing, 250.0)
                    Picker("Seconds", selection: $seconds){
                        ForEach(1..<60) { second in
                            Text("\(second)").tag(second)
                        }
                    }
                    .padding(.trailing, 250.0)
                }
                .listStyle(.bordered)
                .frame(width: 550.0, height: 150.0)
            } else {
                HStack {
                    TextField("Hours", text: $inputHours)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100.0)
                    TextField("Minutes", text: $inputMinutes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100.0)
                    TextField("Seconds", text: $inputSeconds)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100.0)
                }
            }
            
            HStack {
                Button(action: {
                    seconds = 1
                    minutes = 0
                    hours = 0
                    inputHours = ""
                    inputMinutes = ""
                    inputSeconds = ""
                    timerWorkItem?.cancel()
                    countdownTimer?.invalidate()
                }, label: {
                    Text("Cancel")
                        .foregroundColor(.red)
                })
                
                Spacer()
                
                Button(action: {
                    if type == "Input" {
                        if let inputHours = Int(inputHours), let inputMinutes = Int(inputMinutes), let inputSeconds = Int(inputSeconds) {
                            hours = inputHours
                            minutes = inputMinutes
                            seconds = inputSeconds
                        }
                    }

                    print("Setting timer for \(hours) hours, \(minutes) minutes, \(seconds) seconds")
                    
                    remainingTime = totalSeconds

                    timerWorkItem = DispatchWorkItem {
                        startScreenSleep()
                    }

                    countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                        if remainingTime > 0 {
                            remainingTime -= 1
                        }
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(totalSeconds), execute: timerWorkItem!)
                }, label: {
                    Text("Click to set timer!")
                        .font(.headline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                })
            }

            Text("Remaining Time: \(formattedTime)")
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
        }
        .padding()
        .frame(width: 600.0, height: 350.0)
    }
}

#Preview {
    ContentView()
}

func startScreenSleep() {
    DispatchQueue.global(qos: .background).async {
        let script = "tell application \"System Events\" to sleep"
        guard let appleScript = NSAppleScript(source: script) else { return }
        var error: NSDictionary?
        appleScript.executeAndReturnError(&error)
        if let error = error {
            DispatchQueue.main.async {
                print(error[NSAppleScript.errorAppName] as! String)
                print(error[NSAppleScript.errorBriefMessage] as! String)
                print(error[NSAppleScript.errorMessage] as! String)
                print(error[NSAppleScript.errorNumber] as! NSNumber)
                print(error[NSAppleScript.errorRange] as! NSRange)
            }
        }
    }
}
