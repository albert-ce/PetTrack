![PetTrack Banner](./assets/images/logo.png)

# 🐾 PetTrack

**PetTrack** és una aplicació dissenyada per facilitar la gestió del benestar de les mascotes. El projecte ha estat desenvolupat com a part del repte **"Hackathons of Cloud Services: Co-creating and deploying"** dins l’assignatura de **Sistemes Multimèdia 2024–2025**.

## 📱 Descripció del projecte

PetTrack permet als usuaris controlar diferents aspectes de la vida de la seva mascota des d’un sol lloc. Entre les funcionalitats principals s'inclouen:

- 📋 Enregistrament de la fitxa tècnica de la mascota
- 🍽️ Gestió de la dieta
- 🗺️ Registre i visualització de rutes de passeig
- 🗓️ Calendari amb recordatoris per a cites veterinàries, medicació, higiene, etc.

## 👨‍💻 Membres de l'equip

- **Albert Capdevila Estadella** – 1587933  
- **Luis Martínez Zamora** – 1668180  
- **Levon Kesoyan Galstyan** – 1668018

## ☁️ Tecnologies i serveis utilitzats

### Google Cloud
- 🔐 **Firebase Authentication** – Gestió d'autenticació d'usuaris
- 🔥 **Cloud Firestore** – Base de dades NoSQL per emmagatzemar informació
- 📆 **Google Calendar API** – Integració de recordatoris i esdeveniments
- 🗺️ **Google Maps API** – Visualització i registre de rutes
- ☁️ **Cloud Functions** – Lògica del backend escalable
- 🧠 **Gemini API** – Integració d’intel·ligència artificial generativa

### Altres
- 🐕 **Siwalu API** *(pendent de permís)* – Per reconeixement o informació addicional sobre mascotes

## 🏗️ Arquitectura

L’aplicació està basada en una arquitectura client-servidor moderna, on el frontend interactua amb diversos serveis de Google Cloud a través d’APIs i funcions al núvol.

## 🚀 Com començar

1. Clona el repositori:
   ```bash
   git clone https://github.com/nom-del-teu-usuari/PetTrack.git
   cd PetTrack
