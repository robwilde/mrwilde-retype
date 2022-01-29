---
author:
    name: Robert Wilde
    avatar: https://en.gravatar.com/userimage/147698178/ba5af134d07fd7ed2f40436cf2c568ce.jpeg
    email: robert@mrwilde.com
description: the back-door to your WordPress website
category: Tools
tags: [wordpress, cli]
date: 2018-03-08
---

# What is WP-CLI and what can it do for you?

### So what is WP-CLI?

WP-CLI or the WordPress Command Line Interface is a PHP based tool that allows you to manage your WordPress site via SSH (Secure Shell) interface.

In simpler terms, it is the back-door to your website. WP-Admin is the GUI or Graphical User interface gives you something nice to look at, with buttons and colours that can be accessed via a web page. WP-CLI drops the GUI and works with simple commands, providing more control and speed.

### Why should you use WP-CLI?

This will depend on whether you manage one site or multiple sites but there is always benefit to using WP-CLI. When I am doing regular maintenance on a site or inspecting a client site for the first time there are several commands I always run.

```shell shows the current plugins and their status
wp plugin status
```

```shell shows the current themes and their status
wp theme status
```

```shell check the core WordPress install and if there are any updates available
wp core check-update
```

### Fundamentals of a WP-CLI command

```shell force install of specific WordPress version
wp core update --version=4.9.1 --force
```

WP-CLI install page has details on how to add tab completions, so you just hit tab and get a list of available commands, 
sub-commands and options. [https://wp-cli.org](https://wp-cli.org)

### Let's dig deeper and see what we can do!

=== Managing Users
```shell show all the current users
wp user list
```

```shell update a user password
wp user update 2 --user_pass=Its@Secret!
```

```shell update a user password
wp user update 2 --user_pass=Its@Secret!
```

```shell delete a user by username
wp user delete iamnewuser
```
===
Also a number of maintenance tools for DB as well but be very careful running them. Best rule if you are not sure, don't run them.
=== Database Management
```shell export the database to pluginupdate.sql
wp db export pluginupdate.sql
```
```shell import a previous or new database overwriting the current install
wp db import pluginupdate.sql
```
```shell search the database for old url and replace with the new one
wp search-replace "//yoursite.com" "//staging.yoursite.com" --dry-run
```
```shell repairs the db with mysqlcheck utility with --repair=true
wp db repair
```
```shell Optimizes the database running mysqlcheck with optimize true
wp db optimize
```
```shell Reset the current database. wp db reset # Drop an existing database.
wp db drop
```
===
=== Posts
```shell list all pages
wp post list --post_type=page --fields=post_title,post_statuses
```
```shell List posts in CSV
wp post list --post_type=post --posts_per_page=5 --format=csv
```
``` shell  create a list of post types in a csv format then save to a file
wp post list --post_type=post --posts_per_page=5 --format=csv > posts.csv
```
===

### Building and Scaffolding Sites

Here are some more detailed commands for building and setting up your sites. You will need a database in place before you begin.

```shell download
wp core wp core download
```
```shell create and configure wp-config.php
wp core config --dbname=mrwilde_database --dbuser=mrwilde_user --dbpass=mrwilde_password --dbhost=localhost --dbprefix=mrwilde_
```
```shell complete the WordPress install
wp core install --url=mrwilde.com --title="Mr Wilde's Website" --admin_user=admin_user --admin_password=admin_password --admin_email="robert@mrwilde.com"
```
```shell Install several plugins and activiate
wp plugin install query-monitor developer php-compatibility-checker theme-checker --activate
```
```shell create a child theme for the WordPress default Twenty Seventeen Theme
wp scaffold child-theme mrwilde-theme --parent_theme=twentyseventeen --theme_name='MrWilde New Theme' --author='Robert Wilde' --author_uri=https://mrwilde.com --theme_uri=https://mrwilde.com --activate
```

### Advanced commands and Piping
Here a some more advanced commands that you can use for testing and fault-finding. 
I would highly advise you don't use these on a production server as they will change your site and possibly prevent it from being accessed via a web page.

These commands are for development & staging environments only and make sure you do a wp db export database-name.sql first as insurance.

```shell regenerate thumbnails for PDF files added before WordPress 4.7
wp post list --post_type=attachment --post_mime_type=application/pdf --format=ids | xargs wp media regenerate
```
```shell Combining wp post list with
wp post delete lets you easily delete all posts.
```
```shell In this example, $() lets us pass the space-separated page ids to
wp post delete wp post delete $(wp post list --post_type='page' --format=ids) // run a commands remotely on a site wp user list --ssh=robert@mrwilde.com/var/www
```
```shell installing the current version in development
wp core download --version=nightly --force
```

That is only a small sample of commands for WP-CLI. Here are some links for beginners and advanced users as well as a few posts on how to install WP-CLI on your host.

- [Home of WP_CLI](https://wp-cli.org/)
- [Beginners Guide to WP-CLI](https://code.tutsplus.com/tutorials/what-is-wp-cli-a-beginners-guide--cms-28649)
- [WP-CLI Tips by John Blackbourn (Creator of Query-Monitor)](https://tinyletter.com/wp-cli-tips)
- [WP-CLI – Advanced WordPress Management](https://www.smashingmagazine.com/2015/09/wordpress-management-with-wp-cli/)
- [Other External Resources](https://make.wordpress.org/cli/handbook/external-resources/)

=== Installing on Shared Host
- https://swapnil.blog/2018/01/10/installing-wp-cli-on-shared-hosting/
- https://au.godaddy.com/help/how-to-install-wordpress-cli-on-shared-hosting-12363
===

