//
//  ScannerView.swift
//  QRCodeScanner
//
//  Created by Thongchai Subsaidee on 23/4/23.
//

import SwiftUI
import AVKit

struct ScannerView: View {
    
    //QR Code Scanner properties
    @State private var isScanning: Bool = false
    @State private var session: AVCaptureSession = .init()
    @State private var cameraPermission: Permission = .idle
    
    //QR Code Scanner AV Output
    @State private var qrOutput: AVCaptureMetadataOutput = .init()
    
    //Error Properties
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(spacing: 8) {
            Button {
                
            } label: {
                Image(systemName: "xmark")
                    .font(.title)
                    .foregroundColor(Color("Blue"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Place the QR code inside the area")
                .font(.title3)
                .foregroundColor(.black.opacity(0.8))
                .padding(.top, 20)
            
            Text("Scanning will start automatically")
                .font(.callout)
                .foregroundColor(.gray)
            
            Spacer(minLength: 0)
            
            //Scanner
            GeometryReader {
                let size = $0.size
                
                
                ZStack {
                    
                    CameraView(frameSize: size, session: $session)
                    
                    ForEach(0...4, id: \.self) { index in
                        let rotation = Double(index) * 90

                        RoundedRectangle(cornerRadius: 2, style: .circular)
                            // Trimming to get Scanner like Edges
                            .trim(from: 0.61, to: 0.64)
                            .stroke(Color("Blue"), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                            .rotationEffect(.init(degrees: rotation))
                        
                    }

                }
                // Sqaure Shape
                .frame(width: size.width, height: size.width)
                
                //Scanner Animation
                .overlay(alignment: .top,content: {
                    
                    Rectangle()
                        .fill(Color("Blue"))
                        .frame(height: 2.5)
                        .shadow(color: .black.opacity(0.8), radius: 8, x: 0, y: isScanning ? 15 : 0)
                        .offset(y: isScanning ? size.width : 0)
                        
                })
                
                // To Make it Center
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
            .padding(.horizontal, 45)
            
            Spacer(minLength: 15)
            
            Button {
                
            } label: {
                Image(systemName: "qrcode.viewfinder")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }

            Spacer(minLength: 45)
        }
        .padding(15)
        //Checing camera permitssion, When the view is visible
        .onAppear(perform: checkCameraPermission)
        .alert(errorMessage, isPresented: $showError) {
            // Showing setting's button, if premission is denied
            if cameraPermission == .denied{
                
                Button("Settings") {
                    let settingString = UIApplication.openSettingsURLString
                    if let settingsURL = URL(string: settingString) {
                        //Opening app's setting, using openURL swiftAPI
                        openURL(settingsURL)
                    }
                }
                
                
                //Along with cancel button
                Button("Cancel", role: .cancel) {
                    
                }
                
            }
        }

    }
    
    //Activating Scnner Animation Method
    func activateScannerAnimation() {
        // Adding Delay for Each Reversal
        withAnimation(.easeInOut(duration: 0.85).delay(0.1).repeatForever(autoreverses: true)){
            isScanning = true
        }
    }
    
    //Checking Camera Permission
    func checkCameraPermission() {
        Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                cameraPermission = .approved
            case .notDetermined:
                //Request Camera Access
                if await AVCaptureDevice.requestAccess(for: .video){
                    // Permission Graned
                    cameraPermission = .approved
                }else {
                    // Permission Denied
                    cameraPermission = .denied
                    // Presention error message
                    presentError("Please provide access to camera for scanning codes")
                }
            case .denied, .restricted:
                cameraPermission = .denied
                presentError("Please provide access to camera for scanning codes")
            default: break
            }
        }
    }
    
    func presentError(_ message: String) {
        errorMessage = message
        showError.toggle()
    }
    
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
