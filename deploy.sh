#!/bin/bash

# Script de déploiement sur GitHub
echo "🚀 Déploiement de l'application MOYOO Delivery sur GitHub..."

# Vérifier si Git est installé
if ! command -v git &> /dev/null; then
    echo "❌ Git n'est pas installé. Veuillez installer Git d'abord."
    exit 1
fi

# Initialiser Git si ce n'est pas déjà fait
if [ ! -d ".git" ]; then
    echo "📁 Initialisation du repository Git..."
    git init
fi

# Ajouter tous les fichiers
echo "📦 Ajout des fichiers au repository..."
git add .

# Faire le premier commit
echo "💾 Création du commit initial..."
git commit -m "🎉 Initial commit: MOYOO Delivery App Mobile

✨ Fonctionnalités implémentées:
- Authentification complète avec JWT
- Gestion des livraisons (démarrer, terminer, annuler)
- Gestion des ramassages (démarrer, finaliser, annuler)
- Notifications locales et push Firebase
- Interface utilisateur moderne avec GetX
- Gestion d'erreurs avancée
- Pagination et filtres avancés
- Shimmer loading effects
- Dialog spécialisés pour les livraisons actives

🛠️ Technologies:
- Flutter 3.0+
- GetX pour la gestion d'état
- Firebase pour les notifications
- HTTP pour l'API
- SharedPreferences pour le stockage local"

# Configurer la branche main
echo "🌿 Configuration de la branche main..."
git branch -M main

# Ajouter le remote origin
echo "🔗 Ajout du remote GitHub..."
git remote add origin https://github.com/joeldjebi/moyoo-delivery-app-mobile.git

# Pousser vers GitHub
echo "⬆️ Poussée vers GitHub..."
git push -u origin main

echo "✅ Déploiement terminé avec succès!"
echo "🌐 Votre application est maintenant disponible sur:"
echo "   https://github.com/joeldjebi/moyoo-delivery-app-mobile"
