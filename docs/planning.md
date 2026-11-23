# Planning de réalisation (travail individuel)

Estimations en jours de travail pleins, à recalibrer après la phase 3.

| Phase | Contenu | Jours | Priorité |
|---|---|---|---|
| 1 | Cadrage | 1 | Indispensable |
| 2 | Contrats (XSD, WSDL, proto, OpenAPI) | 3 | Indispensable |
| 3 | Squelette, Dockerfiles, Compose | 3 | Indispensable |
| 4 | Services techniques (SOAP, gRPC) | 6 | Indispensable |
| 5 | Simulateur | 3 | Indispensable |
| 6 | Services REST et machine à états | 7 | Indispensable |
| 7 | Intégration | 5 | Indispensable |
| 8 | Résilience | 4 | Indispensable |
| 9 | Mobile V1 | 7 | Souhaitable |
| 10 | Mobile avancé | 5 | Optionnel |
| 11 | Tests et qualité | 4 | Indispensable |
| 12 | Bonus | 3 | Optionnel |
| 13 | Documentation, rapport | 4 | Indispensable |
| 14 | Soutenance | 2 | Indispensable |

Total sans phases 10 et 12 : environ 49 jours. Avec : environ 57 jours.

## Jalons
- J1 (fin phase 3) : `docker compose up` démarre tous les services vides en bonne santé.
- J2 (fin phase 5) : les mesures circulent du simulateur vers les services gRPC.
- J3 (fin phase 8) : scénario de coupure de bout en bout, panne d'un service démontrée.
  À ce stade, tous les critères techniques de la grille sont couverts.

## Lignes de coupe (si le temps manque)
1. Supprimer la phase 10 (mobile avancé).
2. Réduire le mobile V1 à 3 écrans : Ce soir, Planifier, Session en direct.
3. Limiter les bonus à ceux de faible coût : Testcontainers, JWT, CI GitHub Actions.
4. Ne jamais sacrifier : contrats, Docker, résilience démontrée, tests, README.

## Ordre des bonus (coût croissant)
Testcontainers, CI, JWT, RabbitMQ, traçage OpenTelemetry, FCM (à éviter).

## Règles Git
- `main` toujours fonctionnelle.
- Une branche par fonctionnalité : feature/contrats-soap, feature/scheduler-state-machine.
- Pull request vers main, même seule.
- Commits petits et fréquents, au moins un par session de travail.
- Préfixes : feat, fix, docs, test, chore, refactor.