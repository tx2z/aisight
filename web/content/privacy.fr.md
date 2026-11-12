---
title: "Politique de Confidentialité"
description: "Politique de Confidentialité d'AISight. Nous ne collectons, ne stockons ni ne transmettons vos données personnelles. Le traitement IA se fait par défaut sur votre appareil."
layout: "single"
---

# Politique de Confidentialité

*Dernière mise à jour : 11 novembre 2026*

## Notre Engagement en Matière de Confidentialité

AISight est conçu avec la confidentialité comme principe fondamental. Nous ne collectons, ne stockons ni ne transmettons vos données personnelles à des serveurs externes que nous exploitons. Il n'y a ni analyse, ni suivi, ni publicité, ni comptes utilisateur. Vos données restent sur votre appareil. Les seules exceptions sont les requêtes réseau et le traitement IA décrits ci-dessous.

## Informations Que Nous Ne Collectons Pas

AISight ne collecte pas :

- Les identifiants personnels (nom, adresse e-mail, numéro de téléphone)
- Les identifiants d'appareil à des fins de suivi
- Les données de localisation
- Les analyses d'utilisation ou la télémétrie
- Les identifiants publicitaires
- Les cookies ou empreintes de navigateur

Nous ne vendons, ne louons, ne partageons ni ne monétisons jamais les données des utilisateurs — jamais.

## Données Stockées sur Votre Appareil

AISight stocke les données suivantes localement, uniquement sur votre appareil :

**Historique de recherche :** Vos requêtes de recherche et les réponses générées par l'IA sont enregistrées sur votre appareil à l'aide du framework SwiftData d'Apple. Ces données ne quittent jamais votre appareil, sauf si vous choisissez de les partager.

**Préférences :** Les paramètres de votre application (préférences linguistiques, URL du serveur SearXNG) sont stockés dans UserDefaults sur votre appareil.

Vous pouvez supprimer toutes les données stockées localement à tout moment depuis Réglages → Données → Supprimer toutes les données.

Réglages du fournisseur d'IA personnalisé : si vous configurez un fournisseur d'IA personnalisé, son URL, son nom de modèle et sa taille de contexte sont stockés dans UserDefaults sur votre appareil, et sa clé d'API dans le trousseau de l'appareil, uniquement sur cet appareil. La suppression de toutes les données dans les Réglages les supprime également.

## Données Transmises sur le Réseau

AISight effectue jusqu'à quatre types de requêtes réseau :

1. **Requêtes de recherche :** Lorsque vous effectuez une recherche, votre requête est envoyée au serveur SearXNG que vous avez configuré. AISight n'exploite pas ce serveur — c'est vous qui le fournissez et le contrôlez. La confidentialité de vos requêtes de recherche dépend de la configuration de votre instance SearXNG.

2. **Récupération de contenu web :** AISight récupère des pages web accessibles au public à partir des URL retournées par les résultats de recherche afin d'extraire le contenu textuel pour la synthèse par IA. Il s'agit de requêtes HTTP standard, similaires à la visite d'un site web dans un navigateur.

AISight n'ajoute pas de paramètres de suivi, d'en-têtes personnalisés ou d'informations permettant de vous identifier à ces requêtes au-delà de ce qui est standard pour le chargement d'URL sur iOS/macOS.

3. Apple Private Cloud Compute (facultatif) : Ce n'est que si vous l'activez dans les Réglages que votre question, le texte extrait des sources web et les instructions de l'IA sont envoyés au service Private Cloud Compute d'Apple pour rédiger la réponse.

4. Fournisseur d'IA personnalisé (facultatif) : Ce n'est que si vous en configurez un et acceptez la demande de confirmation dans les Réglages que votre question, le texte extrait des sources web et les instructions de l'IA sont envoyés au serveur de ce fournisseur. La recherche approfondie envoie plusieurs requêtes par question. Les conditions et pratiques de confidentialité propres au fournisseur s'appliquent.

## Traitement IA

Par défaut, tout le traitement IA dans AISight se fait entièrement sur votre appareil à l'aide du framework FoundationModels d'Apple (Apple Intelligence). Vos requêtes, résultats de recherche et réponses générées ne sont envoyés à aucun service d'IA cloud. Si vous choisissez « Apple Private Cloud Compute » dans Réglages → Modèle d'IA, votre requête et les résultats de recherche nécessaires à la rédaction d'une réponse sont alors traités sur les serveurs Private Cloud Compute d'Apple, avec les protections de confidentialité d'Apple pour ce service. Vous pouvez revenir à l'option « Sur l'appareil » à tout moment. Si vous configurez un fournisseur d'IA personnalisé dans Réglages → Modèle d'IA et acceptez la demande de confirmation, votre question, le texte extrait des sources web et les instructions de l'IA sont envoyés à ce fournisseur selon ses propres conditions ; la recherche approfondie envoie plusieurs requêtes. La clé d'API est stockée dans le trousseau de votre appareil et n'est envoyée qu'à ce fournisseur.

## Services Tiers

AISight lui-même ne s'intègre à aucun service tiers d'analyse, de publicité, de rapport de plantage ou de collecte de données.

Votre instance SearXNG auto-hébergée peut avoir ses propres pratiques en matière de données selon sa configuration. Nous vous recommandons de consulter la documentation de SearXNG pour plus de détails.

Les pages web récupérées pendant la recherche peuvent contenir leurs propres mécanismes de suivi, mais AISight n'extrait que le contenu en texte brut et n'exécute pas de JavaScript ni ne charge de ressources de suivi.

## Confidentialité des Enfants

AISight ne collecte sciemment aucune information personnelle de quiconque, y compris les enfants de moins de 13 ans. Étant donné que nous ne collectons pas de données personnelles, il n'y a pas de données d'enfants à gérer. Cependant, le contenu généré par l'IA peut ne pas toujours être approprié pour tous les âges. La surveillance parentale est recommandée.

## Vos Droits

Étant donné qu'AISight ne collecte ni ne stocke vos données personnelles sur un serveur externe, de nombreux droits traditionnels en matière de données sont satisfaits par conception :

- **Droit d'accès :** Toutes vos données sont stockées localement sur votre appareil et vous sont accessibles.
- **Droit à l'effacement :** Vous pouvez supprimer toutes les données de l'application depuis les Réglages à tout moment, ou en supprimant l'application.
- **Droit à la portabilité des données :** Vos données sont stockées dans des formats standard sur votre appareil.
- **Droit de refuser la vente :** Nous ne vendons jamais vos données.

Ces droits s'appliquent aux utilisateurs de toutes les juridictions, y compris dans le cadre du Règlement Général sur la Protection des Données (RGPD) de l'UE et du California Consumer Privacy Act (CCPA).

## Sécurité

Vos données sont protégées par les fonctionnalités de sécurité intégrées à votre appareil Apple, notamment le chiffrement de l'appareil, l'isolation des applications (sandboxing) et les verrouillages biométriques ou par code. Étant donné qu'AISight stocke les données uniquement sur votre appareil à l'aide des frameworks d'Apple, vos données bénéficient de l'architecture de sécurité complète d'iOS et macOS.

Les requêtes réseau vers votre instance SearXNG et les sites web sources utilisent le chiffrement HTTPS standard lorsque le serveur le prend en charge.

## Conservation des Données

L'historique de recherche est conservé sur votre appareil jusqu'à ce que vous le supprimiez explicitement. Aucune donnée n'est conservée sur un serveur externe exploité par nous. Lorsque vous supprimez l'application, toutes les données stockées localement sont supprimées. La suppression de toutes les données dans les Réglages supprime également la clé d'API et les réglages de votre fournisseur personnalisé.

## Ce Site Web

Ce site web (private-search-intelligence.app) n'utilise ni cookies, ni analyse, ni suivi. Le formulaire de contact envoie votre message directement par e-mail et nous ne stockons pas vos données sur un serveur.

## Modifications de Cette Politique

Nous pouvons mettre à jour cette politique de confidentialité de temps en temps. Les modifications seront reflétées dans l'application avec une date de « Dernière mise à jour » actualisée. L'utilisation continue de l'application après les modifications constitue l'acceptation de la politique mise à jour.

## Contact

Si vous avez des questions concernant cette politique de confidentialité, veuillez nous contacter à [jesus@perezpaz.es](mailto:jesus@perezpaz.es).
