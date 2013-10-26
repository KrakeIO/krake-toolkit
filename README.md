# krake-toolkit

A package of common methods used in [Krake's Web Scraping Engine] (https://krake.io)

## Pre-requisities
- NodeJS — v0.8.8
- Coffee-Script

## Folder structure
### Lib
classes in this folder are organized into 3 types
- query
- data
- usage

#### query
Classes that support the manipulation and conversion of Krake definitions into various formats

#### data
Classes that act as adaptors for writing extracted data to various Databases. 
Supported databases includes
- MongoDB
- MySQL
- Postgresql - HSTORE

#### Usage
Classes that act as clients to hook Krake slaves to the central Krake clustered computing webscraping infrastructure

## Setup

```console
git clone git@github.com:KrakeIO/krake-toolkit.git
cd krake-toolkit
npm install
```