# XM Cloud dev tools

## Introduction
Welcome to a collection of scripts I developed to optimize the utilization the environments in the projects of an XM Cloud subscription in the best way.
In our company subscription to XM Cloud we have two projects, and each project has 3 environments: 2 non-production, and one production environment.
For development and research we want to be able to use each environment separately. These scripts make this possible, without giving users direct access to XM Cloud deploy.

This code is a further evolution of the scripts I developed for the blog post [XM Cloud build and deploy like a pro](https://www.sergevandenoever.nl/XM_Cloud_build_and_deploy_like_a_pro/). Read the blogpost for the underlying ideas for the scripts.

## Prerequisites
Copy this script folder into an sxa-starter headstart based solution. See https://github.com/sitecorelabs/xmcloud-foundation-head for more information on the headstart. 

## The tools

See [xmc-config.md](scripts/xmc-config.md) for more information on the tools and the required configuration file.

## Keep in sync with the headstart

The script `scripts/Compare-Headstart.ps1` compares the headstart with the current solution. See the blogpost [XM Cloud - stay in sync with the headstart](https://www.sergevandenoever.nl/XM_Cloud_stay_in_sync_with_the_headstart/) for more information.
