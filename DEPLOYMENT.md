# Deployment Instructions

## After Git Pull on Production Server

If new features (like Exams, Essays) are not showing in the sidebar after git pull, run these commands:

### Quick Fix (Recommended)
```bash
composer dump-autoload
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan clear-compiled
```

### Full Deployment Steps

1. **SSH into your production server**
2. **Navigate to project directory**
   ```bash
   cd /path/to/your/project
   ```

3. **Pull latest code**
   ```bash
   git pull origin main
   # or
   git pull origin master
   ```

4. **Regenerate Composer autoloader** (IMPORTANT for new classes!)
   ```bash
   composer dump-autoload
   ```

5. **Clear all Laravel caches**
   ```bash
   php artisan cache:clear
   php artisan config:clear
   php artisan route:clear
   php artisan view:clear
   php artisan clear-compiled
   ```

6. **Run migrations (if new tables were added)**
   ```bash
   php artisan migrate --force
   ```

7. **Set proper permissions**
   ```bash
   chmod -R 755 storage bootstrap/cache
   chown -R www-data:www-data storage bootstrap/cache
   ```

8. **Clear browser cache** (Important!)
   - Press `Ctrl + Shift + Delete` (or `Cmd + Shift + Delete` on Mac)
   - Or hard refresh: `Ctrl + F5` (Windows) / `Cmd + Shift + R` (Mac)

### Verify Routes Are Registered

Check if routes are properly registered:
```bash
php artisan route:list | grep exams
php artisan route:list | grep essays
```

### If Still Not Working

1. **Check .env file**
   - Ensure `APP_ENV=production` (or your environment)
   - Ensure `APP_DEBUG=false` in production

2. **Check file permissions**
   ```bash
   ls -la resources/views/layouts/master.blade.php
   ```

3. **Check if routes exist in routes/admin.php**
   ```bash
   grep -n "exams\|essays" routes/admin.php
   ```

4. **Restart web server** (if using PHP-FPM)
   ```bash
   sudo service php8.1-fpm restart
   # or
   sudo systemctl restart php-fpm
   ```

### One-Line Command

You can also run all commands in one line:
```bash
composer dump-autoload && php artisan cache:clear && php artisan config:clear && php artisan route:clear && php artisan view:clear && php artisan clear-compiled
```

### Using the Deploy Script

If you uploaded the `deploy.sh` script:
```bash
chmod +x deploy.sh
./deploy.sh
```

