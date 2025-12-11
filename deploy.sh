#!/bin/bash

# Laravel Deployment Script
# Run this script on your production server after git pull

echo "🚀 Starting Laravel deployment..."

# Clear application cache
echo "📦 Clearing application cache..."
php artisan cache:clear

# Clear config cache
echo "⚙️  Clearing config cache..."
php artisan config:clear

# Clear route cache
echo "🛣️  Clearing route cache..."
php artisan route:clear

# Clear view cache
echo "👁️  Clearing view cache..."
php artisan view:clear

# Clear compiled files
echo "🔨 Clearing compiled files..."
php artisan clear-compiled

# Optimize for production (optional - only if you want to cache)
# echo "⚡ Optimizing for production..."
# php artisan config:cache
# php artisan route:cache
# php artisan view:cache

# Run migrations (if needed)
# echo "📊 Running migrations..."
# php artisan migrate --force

echo "✅ Deployment complete!"
echo ""
echo "⚠️  If menu items still don't show:"
echo "   1. Check file permissions: chmod -R 755 storage bootstrap/cache"
echo "   2. Check .env file has correct APP_ENV"
echo "   3. Clear browser cache"
echo "   4. Check if routes are registered: php artisan route:list | grep exams"

