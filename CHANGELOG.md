# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/).

## [Unreleased]

## [0.15.0] - 2024-06-18
### Changed
- Don't toggle switches on websocket reconnects

## [0.14.0] - 2023-08-20
### Added
- Add support for phx-live 0.19 and phx 1.7 by @ananthakumaran
### Breaking Changes
- Drop support for LiveView 0.17

## [0.13.0] - 2022-11-25
### Added
- Add support for exq_scheduler on UI #124 by @ananthakumaran
### Changed
- Add support for phx-live 0.18 #125 by @ananthakumaran
### Breaking Changes
- Drop support for LiveView 0.16

## [0.12.3] - 2022-08-12
### Fixed
- respect live_socket_path config option #119 by @ananthakumaran

## [0.12.2] - 2022-05-07
### Fixed
- Fix compile issue for missing id attribute #117 by @williamweckl

## [0.12.1] - 2022-02-15
### Added
- Support phoenix\_live\_view 0.17 #109 by @ananthakumaran
- Add :live_session_on_mount option #110 by @neslinesli93
- Add toggle switch per node to unsubscibe from all queues #114 by @ananthakumaran

### Changed
- Use relative time format #113 by @ananthakumaran
- improve table layout #111 by @ananthakumaran

## [0.12.0] - 2021-12-12

## Changed
- Complete rewrite using Phoenix Liveview #102 by @ananthakumaran!! NOTE: Needs upgrade of Exq to 0.16.0.


### Fixed


### Added
- Add more options to scheduled and retry page #104 by @ananthakumaran


## [0.11.1] - 2021-09-06

### Fixed
- Avoid JsonApi module class by adding ExqUi prefix by @yknx4
- Fix warming on Erlang release greater than 21 by @AllanKlaus
- Fix busy tab display by Chau Hong Linh

## Changed
- Upgrade Ember CLI by Chau Hong Linh

### Added
- Add visibility into failed jobs by @drteeth #77
