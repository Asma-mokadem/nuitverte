# Hypothèses de simulation : NuitVerte

Borne, voiture et réseau sont simulés. Les valeurs ci-dessous sont des hypothèses de
travail, pas des mesures réelles. Elles ne reproduisent aucune interface réelle de la STEG.

## 1. Réseau électrique
| Paramètre | Valeur | Origine | Justification |
|---|---|---|---|
| Tension nominale | 230 V | Reco | Tension monophasée usuelle en Tunisie |
| Fréquence nominale | 50 Hz | Reco | Fréquence du réseau tunisien |
| Seuil de sous-tension | < 207 V | PDF | 230 V - 10 % |
| Durée avant réaction à la sous-tension | > 10 s | PDF | Évite de réagir à un creux bref |
| Seuil de surtension | > 253 V | PDF | 230 V + 10 % |
| Micro-coupures répétées | plus de 3 en 10 min | PDF | Fatigue le chargeur |
| Micro-coupure (définition) | tension absente moins de 5 s | Reco | Distingue d'une vraie coupure |
| Coupure totale (définition) | tension absente 5 s ou plus | Reco | Complément de la ligne précédente |
| Sous-tension persistante | encore présente 60 s après la réduction de puissance | Reco | Le PDF dit « si ça persiste » sans durée |
| Puissance réduite en sous-tension | 50 % de la puissance nominale | Reco | Compromis entre protection et poursuite de la charge |

## 2. Reprise après coupure
| Paramètre | Valeur | Origine |
|---|---|---|
| Attente de tension stable avant reprise | 5 min | PDF |
| Paliers de puissance à la reprise | 25 %, 50 %, 75 %, 100 % | Reco |
| Durée de chaque palier | 60 s | Reco |
| Tension jugée stable | entre 207 V et 253 V, en continu | Reco |

## 3. Pannes injectées par le simulateur
| Commande | Effet | Origine |
|---|---|---|
| POST /sim/outage | Tension à 0 V | PDF |
| POST /sim/undervoltage | Tension à 190 V | PDF |
| POST /sim/overvoltage | Tension à 260 V | PDF |
| POST /sim/flicker | Micro-coupures répétées | PDF |
| POST /sim/restore | Retour à 230 V | PDF |

## 4. Borne et batterie
| Paramètre | Valeur | Origine |
|---|---|---|
| Batterie type | 50 kWh | PDF |
| Puissance de la borne | 7 kW | PDF |
| Modèle de charge | niveau += puissance x durée / capacité | PDF |
| Durée d'une charge complète | environ 7 h | PDF |
| Cadence des mesures | 1 par seconde | PDF |
| Consommation type du véhicule | 16 kWh / 100 km | PDF (exemple) |

## 5. Règles du mobile
| Paramètre | Valeur | Origine |
|---|---|---|
| Réserve de sécurité sur le niveau cible | 15 % | PDF |
| Prédiction de l'heure de départ | h = 0,3 x h_obs + 0,7 x h | PDF |
| Observations avant suggestion | 3 départs, écart inférieur à 30 min | PDF |
| Données anciennes | aucune mesure depuis 30 s | PDF |
| Rayon du géorepérage | 100 m | PDF |

## 6. Indice de stabilité d'une zone (à valider en phase 4)
| Paramètre | Valeur | Origine |
|---|---|---|
| Échelle | 0 à 100 (100 = très stable) | Reco |
| Calcul | 100 moins 20 par anomalie sur la dernière heure, minimum 0 | Reco |
| Seuil du mode prudence | indice inférieur à 50 | Reco |
| Types d'anomalies suivis | 3 : coupure, sous-tension/surtension, micro-coupures | PDF (périmètre réduit) |

## 7. Tarifs (grille fictive, à préciser en phase 4)
| Paramètre | Valeur | Origine |
|---|---|---|
| Heures creuses | 23h à 6h | Reco |
| Heures pleines | 6h à 23h | Reco |
| Unité monétaire | dinar tunisien | PDF |
| Valeurs en dinars | fictives, fixées en phase 4 | Reco |

## 8. Timeouts et repli (tirés du PDF)
| Appel | Timeout | Mécanisme | Repli |
|---|---|---|---|
| scheduler vers utility-gateway (SOAP) | 3 s | retry avec backoff + circuit breaker | tarif en cache, plan prudent |
| scheduler vers charger-control (gRPC) | 2 s | retry limité | session à vérifier, alerte |
| scheduler vers charger-control (mesures) | 1,5 s | circuit breaker | dernières mesures connues |
| scheduler vers tariff (REST) | 2 s | circuit breaker | dernière grille connue |
| déclaration d'incident (SOAP) | 3 s | retry avec backoff | file de rejeu |
| mobile vers gateway (REST) | 5 s | 2 retries avec backoff | cache local, action en file |