# Fiche sujet : NuitVerte Mobile

Module Architecture SOA et Services Web, 2026

## 1. Problème métier
La nuit, un conducteur de véhicule électrique ignore si sa charge a démarré, si une
coupure l'a interrompue et si sa voiture sera prête à l'heure de départ. NuitVerte
planifie la charge aux heures creuses, surveille la qualité du réseau électrique et
réagit aux anomalies (coupure, surtension, sous-tension, micro-coupures) en suspendant
puis en reprenant la charge par paliers. Une application Android informe le conducteur
en direct. Borne, voiture et réseau sont simulés.

## 2. Microservices et responsabilités
| Service | Responsabilité | Stockage |
|---|---|---|
| api-gateway | Point d'entrée unique du mobile, routage | aucun |
| customer-service | Foyers, véhicules, préférences, zone du domicile | PostgreSQL |
| scheduler-service | Plans de charge, machine à états, orchestration, flux d'événements | PostgreSQL |
| tariff-service | Grille tarifaire, coût estimé, économie réalisée | PostgreSQL |
| notification-service | Jetons d'appareil, envoi et historique des notifications | PostgreSQL |
| charger-control-service | Commandes de la borne, mesures de puissance | TimescaleDB |
| grid-quality-service | Tension, fréquence, anomalies, indice de stabilité par zone | TimescaleDB |
| utility-gateway-service | Opérateur d'électricité simulé : tarifs, coupures, incidents | PostgreSQL |
| simulator | Borne et réseau simulés, injection de pannes | mémoire |

## 3. Style de chaque service et justification
| Service | Style | Raison |
|---|---|---|
| customer, scheduler, tariff, notification (via la gateway) | REST | Exposition à un client mobile : JSON, HTTP standard, cache, OpenAPI |
| charger-control, grid-quality | gRPC | Échange interne à haute cadence (1 mesure par seconde), streaming, contrat binaire typé |
| utility-gateway | SOAP | Simule un système hérité d'opérateur public avec schémas XML stricts (contract-first, SOAP Fault) |

Appels inter-services réels : scheduler vers customer, tariff et notification (REST),
scheduler vers charger-control et grid-quality (gRPC), scheduler vers utility-gateway (SOAP).

## 4. Schéma d'architecture
```
[Application Android Kotlin]
          | HTTPS / REST + SSE
[API Gateway]
   |         |          |            |
[customer] [scheduler] [tariff] [notification]
 Postgres   Postgres    Postgres   Postgres
               |
               |-- SOAP ----------> [utility-gateway] (Postgres)
               |-- gRPC ----------> [charger-control] (TimescaleDB)
               |-- gRPC (alertes) -> [grid-quality]   (TimescaleDB)
                                         ^        ^
                      gRPC streaming     |        |
                              [Simulateur borne et réseau]
```
Tout tourne sur un réseau Docker dédié, lancé avec `docker compose up`.