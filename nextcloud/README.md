# Nextcloud

Backup notes
1. put container in maintainance mode using `$ sudo -u www-data php occ maintenance:mode --on` or simply stop the stack temporarily
2. backup nexcloud folder using `rsync -Aavx source_location target_location/nextcloud-dirbkp_`date +"%Y%m%d"`/`
3. backup DB folder using `rsync -Aavx source_location target_location/nextcloud-sqlbkp_`date +"%Y%m%d"`/`
4. turn off maintainance mode using `$ sudo -u www-data php occ maintenance:mode --off` or simply start stack
