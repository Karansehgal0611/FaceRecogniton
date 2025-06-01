# Face Recognition System (Dockerized)

This is a Dockerized face recognition system built as part of my learning journey into Docker and containerization. It uses OpenCV and face recognition libraries to detect and recognize known faces from a video stream or image.

## 📦 Project Structure
```
FACE-RECOGNITION-DOCKER/
├── known_faces/ # Folder to store reference images of known individuals
├── diagnostic.sh # Optional script for system checks or debugging
├── Dockerfile # Main Dockerfile for building the image
├── Dockerfile.backup # Backup version of the Dockerfile
├── docker-compose.yml # Compose file for managing the container
├── face_recognition_system.py # Main Python script for face recognition
├── setup.sh # Optional setup script
├── Docker Documentation.pdf # Learning notes/documentation reference
```

## 🚀 Getting Started

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- Webcam (if using live capture)

### Build the Docker Image
```bash
docker compose build
```

### Run the Container
```bash
docker compose run face-recognition bash
```

### Once inside the container:
```bash
python face_recognition_system.py
```


## 🔧 Configuration
-Place known faces (reference images) in the known_faces/ directory.
-Update the face_recognition_system.py script as needed for your use case.

## 🛠️ Technologies Used
-Python 3
-OpenCV
-face_recognition
-Docker
-Docker Compose

## 📘 Learning Notes
This repository includes a PDF file named Docker Documentation.pdf, which contains my personal notes and learning materials about Docker

---

## Author:
Karan Sehgal 
VIT Vellore
