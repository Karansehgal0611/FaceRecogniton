import cv2
import numpy as np
import face_recognition
import os
import sys

# Set Qt platform to xcb to avoid Wayland issues
os.environ['QT_QPA_PLATFORM'] = 'xcb'

class FaceRecognitionSystem:
    def __init__(self):
        self.known_face_encodings = []
        self.known_face_names = []
        self.known_faces_dir = "known_faces"
        
        if not os.path.exists(self.known_faces_dir):
            os.makedirs(self.known_faces_dir)
        
        self.load_known_faces()
    
    def load_known_faces(self):
        print("\n[SYSTEM] Loading known faces...")
        self.known_face_encodings = []
        self.known_face_names = []
        
        for filename in os.listdir(self.known_faces_dir):
            if filename.lower().endswith((".jpg", ".jpeg", ".png")):
                try:
                    name = os.path.splitext(filename)[0]
                    image_path = os.path.join(self.known_faces_dir, filename)
                    image = face_recognition.load_image_file(image_path)
                    
                    # Get all face encodings (handle multiple faces in one image)
                    encodings = face_recognition.face_encodings(image)
                    
                    if encodings:
                        self.known_face_encodings.append(encodings[0])
                        self.known_face_names.append(name)
                        print(f"Loaded: {name}")
                    else:
                        print(f"No faces found in {filename}")
                except Exception as e:
                    print(f"Error loading {filename}: {str(e)}")
        
        print(f"[SYSTEM] Loaded {len(self.known_face_names)} known faces")

    def record_new_face(self, name):
        cap = cv2.VideoCapture(0)
        if not cap.isOpened():
            print("[ERROR] Could not open webcam!")
            return False
        
        print(f"\n[SYSTEM] Recording face for: {name}")
        print("Look directly at the camera. Press 's' to save, 'q' to quit...")
        
        while True:
            ret, frame = cap.read()
            if not ret:
                print("[ERROR] Couldn't capture frame")
                break
            
            # Convert to RGB for face detection
            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            
            # Display instructions
            display_frame = frame.copy()
            cv2.putText(display_frame, "Press 'S' to Save, 'Q' to Quit", 
                       (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
            
            # Try face detection
            face_locations = face_recognition.face_locations(rgb_frame)
            
            if face_locations:
                # Draw rectangle around face
                top, right, bottom, left = face_locations[0]
                cv2.rectangle(display_frame, (left, top), (right, bottom), (0, 255, 0), 2)
                cv2.putText(display_frame, "Face Detected!", (left, top-10), 
                           cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 1)
            
            cv2.imshow("Recording Face", display_frame)
            
            key = cv2.waitKey(1)
            if key == ord('s'):
                if not face_locations:
                    print("[ERROR] No face detected! Try again.")
                    continue
                
                try:
                    # Save the image
                    filename = f"{name}.jpg"
                    filepath = os.path.join(self.known_faces_dir, filename)
                    cv2.imwrite(filepath, frame)
                    
                    # Add to known faces
                    face_encoding = face_recognition.face_encodings(rgb_frame, face_locations)[0]
                    self.known_face_encodings.append(face_encoding)
                    self.known_face_names.append(name)
                    
                    print(f"[SUCCESS] Saved {filename}")
                    break
                except Exception as e:
                    print(f"[ERROR] Failed to process face: {str(e)}")
                    continue
                    
            elif key == ord('q'):
                print("[SYSTEM] Cancelled recording")
                break
        
        cap.release()
        cv2.destroyAllWindows()
        return True

    def recognize_faces(self):
        if not self.known_face_encodings:
            print("\n[ERROR] No faces in database! Record faces first.")
            return
        
        cap = cv2.VideoCapture(0)
        if not cap.isOpened():
            print("[ERROR] Could not open webcam!")
            return
        
        print("\n[SYSTEM] Starting recognition. Press 'Q' to quit...")
        
        while True:
            ret, frame = cap.read()
            if not ret:
                print("[ERROR] Couldn't capture frame")
                break
            
            # Process every other frame for better performance
            small_frame = cv2.resize(frame, (0, 0), fx=0.5, fy=0.5)
            # Fix: Use proper cv2.cvtColor instead of slicing
            rgb_small_frame = cv2.cvtColor(small_frame, cv2.COLOR_BGR2RGB)
            
            # Find faces
            face_locations = face_recognition.face_locations(rgb_small_frame)
            face_encodings = face_recognition.face_encodings(rgb_small_frame, face_locations)
            
            for (top, right, bottom, left), face_encoding in zip(face_locations, face_encodings):
                # Compare with known faces
                matches = face_recognition.compare_faces(self.known_face_encodings, face_encoding)
                name = "Unknown"
                
                # Use face distance for better accuracy
                face_distances = face_recognition.face_distance(self.known_face_encodings, face_encoding)
                
                if True in matches:
                    best_match_index = np.argmin(face_distances)
                    if matches[best_match_index]:
                        name = self.known_face_names[best_match_index]
                
                # Scale back up face locations
                top *= 2; right *= 2; bottom *= 2; left *= 2
                
                # Draw rectangle and label
                color = (0, 255, 0) if name != "Unknown" else (0, 0, 255)
                cv2.rectangle(frame, (left, top), (right, bottom), color, 2)
                cv2.rectangle(frame, (left, bottom - 35), (right, bottom), color, cv2.FILLED)
                cv2.putText(frame, name, (left + 6, bottom - 6), 
                           cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 1)
            
            cv2.imshow('Face Recognition', frame)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
        
        cap.release()
        cv2.destroyAllWindows()

def main():
    system = FaceRecognitionSystem()
    
    while True:
        print("\n=== Face Recognition System ===")
        print("1. Record new face")
        print("2. Recognize faces")
        print("3. Exit")
        
        choice = input("Enter your choice (1-3): ").strip()
        
        if choice == '1':
            name = input("Enter person's name: ").strip()
            if name:
                system.record_new_face(name)
            else:
                print("[ERROR] Name cannot be empty!")
        elif choice == '2':
            system.recognize_faces()
        elif choice == '3':
            print("[SYSTEM] Exiting...")
            break
        else:
            print("[ERROR] Invalid choice!")

if __name__ == "__main__":
    main()