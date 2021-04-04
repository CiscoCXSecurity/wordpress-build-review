#!/bin/bash
# wordpress-build-review - WordPress Build Review tool.
# Author: David Muñoz Gallardo @ Portcullis Security
# Copyright (C) 2014 dmg@portcullis-security.com
#
#
# License
# -------
# This tool may be used for legal purposes only.  Users take full responsibility
# for any actions performed using this tool.  The author accepts no liability
# for damage caused by this tool.  If you do not accept these condition then
# you are prohibited from using this tool.
#
# In all other respects the GPL version 2 applies:
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# You are encouraged to send comments, improvements or suggestions to
# me at dmg@portcullis-security.com
#
#
# Description
# -----------
# This tool checks the basic security configuration that a WordPress installation should have.
#
# This tool was developed and tested in Linux. However, it should also work on other platforms as long as
# its dependencies (gnu utils) are available. Please let us know if you try running this tool in other platforms,
# your feedback is appreciated.
#
# This tool wont create or edit any folder/file in the system.
# 
# Use of this script is only permitted on systems which you have been granted
# legal permission to perform a security assessment of.  Apart from this 
# condition the GPL v2 applies.
#
# Search the output below for the word '[VV]' for the security issues found. 
# If you don't see it then this script didn't find any problems.
# Search the output below for the word '[WW]' for problems occurred during script 
# execution. These problems must be checked manually.
# Finally search the output below for the word '[II]' for correct issues. 
#
# TODO List
#
# Check if admin user exists. Needs conection to the database.
# More Suggestions?
#
#
#
#
# FAQ
# --------------
#
# Having werid problems with the output?
# - This tool was developed and tested in Linux. However, it should also work on other platforms as long as its dependencies (gnu utils) are available.
# Please let us know if you try running this tool in other platforms, your feedback is appreciated.
# - Make sure you gave the tool the full path of the WordPress root folder.
# - Make sure you have curl and bc installed in your system.
# - Make sure you have read permissions in wp-config.php or try running the tool as ROOT.
# - If nothing of those solve your problems, please feel free to contact me at dmg@portcullis-security.com.
#
# If I fix all the issues found by this tool, is my web application secure?
#   Good question, but you already know the answer. NO. This tool gives you some basic checks for your WordPress installation.
#   There are more checks that this tool does not perform and should be done by a penetration tester. 
# Looking for a web application assessment?
#   Contact us! http://www.portcullis-security.com/company/contact-us/




################ Checking correct execution ##############################

if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ "$1" == "--h" ] || [ $# -ne 1 ] ; then
    echo "This script needs the FULL PATH of your WordPress root folder installation."
    echo "Please, do NOT use relative paths."
    echo "Usage: ./wordpress-build-review.sh /full/path/to/wordpress/root/folder/"
    exit 1
fi


###############  Defining variables ######################################


#These are the default WordPress urls for getting the last versions of WordPress and its plugins. 
wp_version_url="http://api.wordpress.org/core/version-check/1.7/";
wp_plugin_version_url="http://api.wordpress.org/plugins/info/1.0/";

###### Dont edid this unless you know what you are doing ##################

export LC_ALL=C;
export LANG=C;

#Time execution variable
T1=$(date +%s.%N);

VERSION="1.0"

BOLD="\033[1m"
RESET="\033[0m"
GREEN="\033[0;92m"
RED="\033[1;31m"
ORANGE="\033[1;33m"

#Checking that the path finish with a '/' character.
wp_root=$1;
if [[ $wp_root != */ ]]; 
  then wp_root="$wp_root/";
fi


#internet variable
internet=0;

###################### Functions Section #################

#Banner...not much to say
#
banner () {
  echo
  echo "Starting wordpress-build-review v$VERSION at $(date)"
  echo
  echo "by David Muñoz ( dmg@portcullis-security.com )"
  echo
  echo "This tool checks the basic security configuration that a WordPress installation"
  echo "should have."
  echo 
  echo "Use of this script is only permitted on systems which you have been granted" 
  echo "legal permission to perform a security assessment of.  Apart from this "
  echo "condition the GPL v2 applies."
  echo
  echo "Search the output below for the word '[VV]' for the security issues found. "
  echo "If you don't see it then this script didn't find any problems."
  echo "Search the output below for the word '[WW]' for problems occurred during script "
  echo "execution. These problems must be checked manually."
  echo "Finally search the output below for the word '[II]' for correct issues. "
  echo 
}


#formating stuff, again not much to say
#
section_start () {
	echo -e '\n\n################################################'
	echo $1
	echo -e '################################################\n'
}


# Checks if there is internet conection
internet () {

section_start "Checking if there is internet conection"

wget -q --tries=10 --timeout=20 http://google.com
if [[ $? -eq 0 ]]; then
        internet=1
        echo -e ${GREEN}"Internet conection working"${RESET}
else
        internet=0
        echo -e ${ORANGE}"[WW]There is no Internet connection. Some tests will be ignored as Internet connection is required. Please, set up an Internet connection if you dont wanna miss any test"${RESET}
fi

}

# Checks if the user has read permissions in wp-config.php
have_I_permissions()
{
  section_start "Checking if the user has read permissions in wp-config.php";
  
  user=$(whoami);  
  if [ ! -r $wp_root"wp-config.php" ] && [ "$user" != "root" ]; then
    echo -e ${ORANGE}"[WW]WARNING. You need to have read permissions in wp-config.php!"${RESET};
    exit 1
  fi
  
  echo -e ${GREEN}"Correct. User has read permissions in wp-config.php"${RESET};
}


# Check if the file wp-login.php exists
# The recomendation is to change its name.
#
wp_login_check()
{
  section_start "Checking WordPress login url";
  
  if [ -f $wp_root"wp-login.php" ]; then 
    echo -e ${ORANGE}"[VV][001]File wp-login.php found. It is recommended to change its name."${RESET};
  else echo -e ${GREEN}"[II]No wp-login.php file found. Well done!"${RESET};
  fi
}


# Check if the file readme.html exists
# The recomendation is to change its name.
#
wp_readme_check()
{
  section_start "Checking if readme.html file exists";
  
  if [ -f $wp_root"readme.html" ]; then
    echo -e ${RED}"[VV][002]File readme.html found. It is recommended to delete it."${RESET};
  else echo -e ${GREEN}"[II]No readme.html file found. Well done!"${RESET};
  fi 
}


# Check if there is an index.html file in the plugins folder to prevent listing of plugins folders
#
wp_index_plugins_check()
{
  section_start "Checking if index.html file exists in plugins folder";
  
  if [ -f $wp_root"wp-content/plugins/index.html" ] || [ -f $wp_root"wp-content/plugins/index.htm" ] || [ -f $wp_root"wp-content/plugins/index.php" ]; then 
    echo -e ${GREEN}"[II]File index found in the plugins folder. Well done!"${RESET};
  else 
    echo -e ${ORANGE}"[VV][003]No index.html file found in plugins folder. Please create a blank index.html file there or disable directoy listing in the web server."${RESET};
  fi 
}


#Check is WordPress is updated
#
wp_check_version()
{
   section_start "Checking if WordPress is updated";

   version=$(curl -s "$wp_version_url"|grep -oP '\bversion.*?\d"' | cut -d\" -f3) 
   
   installed_version=$(grep wp_version.*= $wp_root"wp-includes/version.php" | cut -d\' -f2)
   
   if [ $version != $installed_version ]; then 
    echo -e ${RED}"[VV][005]The WordPress version installed is out-to-date. Installed version is: $installed_version. Last version is: $version."${RESET};
   else echo -e ${GREEN}"[II]The WordPress version installed is up-to-date. Current version is: $version."${RESET};
   fi
}


#Check if the plugins are updated
#This function checks all the plugins installed (enabled and diabled)
wp_plugin_check_version()
{
  section_start "Checking if the plugins are updated";

  count=$(echo $wp_root | grep -o "/" | wc -l)
  let count+=3;
  for FILE in ${wp_root}wp-content/plugins/*; do
    if [ -d "$FILE" ]; then
      #Getting aviable version of the plugin
      plugin_name=$( echo $FILE | cut -d '/' -f $count );
      plugin_version=$(curl -s $wp_plugin_version_url$plugin_name".json"|grep -oP "\bversion\":\"([0-9]+\.?)+"  | cut -d\" -f3 | tr -d ' ')

      #Getting installed version of the plugin
      if [ "$plugin_version" != "" ]; then
        installed_plugin_version=$(grep -ERiho "version: ([0-9]+\.?)+" $FILE/*.php | head -n1 | cut -d ':' -f2 | tr -d ' ' );
      fi
      
      if [ "$plugin_version" == "" ]; then
        echo -e ${ORANGE}"[WW]No version of <$plugin_name> plugin found. Please check manually."${RESET};
      elif [ "$plugin_version" == "$installed_plugin_version" ]; then
        echo -e ${GREEN}"[II]Plugin $plugin_name is up-to-date. Current version is: $plugin_version."${RESET};
      else 
        echo -e ${RED}"[VV][006]Plugin $plugin_name is out-of-date. Please, update it. Installed version is: $installed_plugin_version. Last version is: $plugin_version."${RESET};
      fi
      
      unset installed_plugin_version;
      unset plugin_version;

    fi
  done
}


#Check if WordPress minor security autoupdate is enabled.
# 
wp_check_security_updates()
{
  section_start "Checking if automatic security updates (minor updates) are enabled";

  grep_output="$(grep -oiP "^define\s*\(\s*[\'\"]\bWP_AUTO_UPDATE_CORE[\'\"]\s*,\s*[\'\"]\bminor|all\s*[\'\"]\s*\);" $wp_root"wp-config.php")";
  
  if [ -z "$grep_output" ]; then
    echo -e ${RED}"[VV][007]No WordPress Security minor updates enabled. Please, enable this feature."${RESET};
  else echo -e ${GREEN}"[II]WordPress Security minor updates enabled"${RESET};
  fi
}


#Check if WordPress database user is not <root>.
# 
wp_check_db_user()
{
  section_start "Checking if WordPress database user is not <root>.";

  grep_output="$(grep -oiP "^define\s*\(\s*[\'\"]\bDB_USER[\'\"]\s*,\s*[\'\"]\broot\s*[\'\"]\s*\);" $wp_root"wp-config.php")";
  
  if [ -z "$grep_output" ]; then echo -e ${GREEN}"[II]The WordPress database user is not root. Well done!"${RESET};
  else 
    echo -e ${RED}"[VV][008]WordPress database user is root, please change it."${RESET};
  fi
}


#Check if SSL is forced in wp-admin and wp-login sections
#Note: This function could throws a false possitive as SSL may still being enforced by the web server.
#
wp_check_admin_ssl()
{
  section_start "Checking if SSL is enabled in wp-admin and wp-login sections";
  
  grep_output="$(grep -oiP "^define\s*\(\s*[\'\"]\bFORCE_SSL_(LOGIN|ADMIN)[\'\"]\s*,\s*\btrue\s*\s*\);" $wp_root"wp-config.php")";
  
  if [ -z "$grep_output" ]; then
    echo -e ${ORANGE}"[VV][009]HTTPS on the LOGIN and ADMIN sections are not enabled in wp-config but SSL may still being enforced by the web server config."${RESET};
  else echo -e ${GREEN}"[II]WordPress SSL login enabled"${RESET};
  fi
}


#Check if WordPress table prefix is not 'wp_'
#
wp_check_table_prefix()
{
  section_start "Checking if tablet WordPress table prefix is not set by default";
  
  grep_output="$(grep -oiP "\\\$table_prefix\s*\=\s*[\'\"]wp\_[\'\"]\s*;" $wp_root"wp-config.php")";
  
  if [ -z "$grep_output" ]; then echo -e ${GREEN}"[II]WordPress Table prefix is not set by default. Well done!"${RESET};
  else
    echo -e ${RED}"[VV][010]WordPress table prefix is set by default <wp_>. Please, consider to change it."${RESET};
  fi
}


#Check if any know WordPress antivirus plugin is installed.
#Please, ignore in case you have any WordPress antivirus plugin not listed below:
#WordFence, WP Security Scan, Sucuri, VIP Scanner, Exploit Scanner, Antivirus, 6scan
#
wp_check_antivirus()
{
  section_start "Check if a WordPress antivirus plugin is installed";
  
  ls_output="$(ls -d ${wp_root}wp-content/plugins/*)";
  grep_output="$(echo "$ls_output" | grep -ie "security" -ie "wordfence" -ie "6scan" -ie "sucuri" -ie "scanner" -ie "antivuris")";

  if [ -z "$grep_output" ]; then echo -e ${RED}"[VV][011]No WordPress Antivirus found. Please, consider to install one."${RESET};
  else echo -e ${GREEN}"[II]WordPress Antivirus found."${RESET};
  fi
}

#Check that all files and folders have correct permissions
#The correct permissions should be 644, 640 or 664 for files and 755 or 750 for folders. Excepts wp-config.php, that should have 600.
#
wp_check_file_permissions()
{
  section_start "Check the correct permissions";

  #Checking file permissions
  correct_files=1;
  for file in $(find $wp_root -type f ! \( -perm 644 -o -perm 640 -o -perm 664 \) ! -name "wp-config.php" ); do 
    echo -e ${RED}"[VV][012]The file $file has $(stat -c "%a" $file) permissions, consider to set it to 644, 640 or 664"${RESET};
    correct_files=0;
  done
  
  if [ "$correct_files" -eq 0 ]; then echo -e ${RED}"[VV]Incorrect file permissions, please correct them."${RESET};
  else echo -e ${GREEN}"[II]File permissions correct."${RESET};
  fi
    
  #Checking folder permissions
  correct_folders=1;
  for folder in $(find $wp_root -type d ! \( -perm 755 -o -perm 750 \) ! -name . ! -name ..); do 
    echo -e ${RED}"[VV][013]The folder $folder has $(stat -c "%a" $folder) permissions, consider to set it to 755 or 750${RESET}";
    correct_folders=0;
  done
  
  if [ "$correct_folders" -eq 0 ]; then echo -e ${RED}"[VV]Incorrect folder permissions, please correct them."${RESET};
  else echo -e ${GREEN}"[II]Folder permissions correct."${RESET};
  fi
  
  #Cheking for wp-config.php correct permissions
  wp_config_perm=$(stat -c "%a" $wp_root"wp-config.php");
  if [ $wp_config_perm -eq 600 ]; then echo -e ${GREEN}"[II]wp-config.php permissions are correct."${RESET};
  else echo -e ${RED}"[VV][014]wp-config has $wp_config_perm, please set it to 600."${RESET};
  fi
}


#Check if there are default content and backup files
#
wp_check_default_content()
{
  section_start "Check default content and backup files";
  
  backup_files=0
  for file in $(find $wp_root -iname "*~" -o -iname "*.bak" -o -iname "*.DS_store" -o -iname "thumbs.db" -o -iname "*.old"); do 
    echo -e ${RED}"[VV][015]File $file found, consider to remove it."${RESET};
    backup_files=1;
  done
  
  if [ "$backup_files" -eq 1 ]; then echo -e ${RED}"[VV]Default or backup files found, please remove them."${RESET};
  else echo -e ${GREEN}"[II]No default or backup files found."${RESET};
  fi
}

#Check if xmlrpc is enabled
#Thanks to KTT for the contribution
wp_check_xmlrpc()
{
section_start "Checking if WordPress xmlrpc is enabled";
 
 grep_output="$(grep -oiP "^add_filter\(\s*[\'\"]\bxmlrpc_enabled[\'\"],\s*[\'\"]\b__return_false\s*[\'\"]\);" $wp_root"wp-config.php")";
  
  if [ -z "$grep_output" ]; then
    echo -e ${RED}"[VV][016]WordPress xmlrpc is enabled. If not required, disable this feature. - ${BOLD}${RED} Insert into wp-config.php : ${ORANGE}add_filter('xmlrpc_nabled', '__return_false'); ${RESET}"
  else echo -e ${GREEN}"[II]WordPress xmlrpc is disabled."${RESET};
  fi
}


#Check if edit themes and updates is enabled
#Thanks to KTT for the contribution
#This can allow code execution on the OS of the server if user is admin. This might not be desired in a shared environment for the admin WordPress user which might not be the server admin user.
wp_check_edit_themes_plugins()
{
section_start "Checking if WordPress Edit Themes and Updates is enabled.";
 
   grep_output="$(grep -oiP "^define\(\s*[\'\"]\bDISALLOW_FILE_EDIT[\'\"],\btrue\);" $wp_root"wp-config.php")";
  
  if [ -z "$grep_output" ]; then
    echo -e ${RED}"[VV][017]WordPress edit themes is enabled. If not required, disable this feature. - ${BOLD}${RED} Insert into wp-config.php : ${ORANGE}define('DISALLOW_FILE_EDIT',true); ${RESET}"
  else echo -e ${GREEN}"[II]WordPress edit themes is disabled."${RESET};
  fi
  
   grep_output="$(grep -oiP "^define\(\s*[\'\"]\bDISALLOW_FILE_MODS[\'\"],\btrue\);" $wp_root"wp-config.php")";
  
  if [ -z "$grep_output" ]; then
    echo -e ${RED}"[VV][018]WordPress edit updates is enabled. If not required, disable this feature. - ${BOLD}${RED} Insert into wp-config.php : ${ORANGE}define('DISALLOW_FILE_MODS',true); ${RESET}"
  else echo -e ${GREEN}"[II]WordPress edit themes is disabled."${RESET};
  fi
  

}

################# Main program ###################

banner;
internet;
have_I_permissions;

################# WordPress checks ################
wp_login_check;
wp_readme_check;
wp_index_plugins_check;

# Only run WordPress version checks if there is internet conection
if [ $internet == 1 ]; then
wp_check_version;
wp_plugin_check_version;
fi


wp_check_security_updates;
wp_check_antivirus;
wp_check_admin_ssl;
wp_check_default_content;
wp_check_file_permissions;
wp_check_table_prefix;
wp_check_db_user;
wp_check_xmlrpc;
wp_check_edit_themes_plugins;


#Time elapsed
T2=$(date +%s.%N);
printf "\n\n######## Scan completed at %s. Total time elapsed: %.3F seconds. ##############\n" "$(date)" "$(echo "$T2 - $T1"|bc )"

#that's all folks.