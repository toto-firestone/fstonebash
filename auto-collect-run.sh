#!/bin/bash
source glob-coord.conf
source master.conf
source function-lib.sh
source tricky-dailies.sh

radish_message_noprompt "FARMING DAILY CURRENCIES"

anti_ad

auto_claim_gifts
auto_exotic_sales

auto_claim_pickaxes
auto_crystal_5_hit

auto_beer_token_10_pull

auto_scarab_10_pull_and_vault

auto_open_10_max_chests
flush_daily_mail
