# Écrans du mobile (périmètre V1 puis avancé)

Le mobile ne parle qu'à l'API Gateway, en REST/JSON, plus un flux SSE.

## V1 (figé avant la phase 10)
| Écran | Contenu | Appels REST | États à gérer |
|---|---|---|---|
| Ce soir | État de la session, batterie, heure de fin prévue, économie du jour | GET /api/v1/sessions/{id}/status, GET /api/v1/customers/{id}/savings | chargement, aucune session, erreur réseau, données anciennes |
| Planifier | Heure de départ préremplie, niveau cible suggéré, validation | POST /api/v1/charging-plans, PATCH /api/v1/charging-plans/{id} | validation, 409 (objectif impossible), degraded: true |
| Session en direct | Courbe de puissance, tension, état, bouton Charge immédiate | GET /api/v1/sessions/{id}/measures?limit=60, GET /api/v1/sessions/{id}/events, POST /api/v1/charging-plans/{id}/overrides | SUSPENDUE, 409 (réseau instable), données anciennes (30 s) |
| Alertes | Historique des coupures et notifications | GET /api/v1/notifications?customerId= | liste vide |

## Avancé (seulement s'il reste du temps)
Véhicule, Économies, Réglages, hors ligne, géorepérage, mode prudence, conseil d'économie.

## Parcours de navigation
Ce soir -> Planifier -> (plan créé) -> Session en direct ; barre du bas : Ce soir, Alertes.

## Croquis (écran Ce soir)
```
+--------------------------+
| Ce soir                  |
| État : EN_COURS          |
| Batterie : 62 %  [====  ]|
| Fin prévue : 05:45       |
| Économie du jour : 1,2 TND|
| [Planifier] [Voir direct]|
+--------------------------+
```