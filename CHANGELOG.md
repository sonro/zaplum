# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### Chess module

- `board` sub module to convert between board representations.

## [0.3.2] - 2024-08-13

### Added

#### Chess module

- `CastleState` and `CastleStatePacked` `none` and `all` constants.
- `PosHash` position hashing.
- Single char `Color` representation.
- `Position` and `PositionPacked`.

## [0.3.1] - 2024-08-13

### Added

#### Chess module

- `BitPieceMap` board representation.
  - `Extended` version for more info.
- `BitBoard` from `Square` slice.
- `CastleState` and `CastleStatePacked`.

## [0.3.0] - 2024-08-13

- `BitBoard` `isEmpty` method.

### Chess module

#### Added

- `BitBoard` `isEmpty` method.

#### Changed

- **BREAKING** `BitBoard` methods now use `Square` instead of `IndexInt`.

## [0.2.1] - 2024-08-13

### Added

#### Chess module

- `PieceMap` board representation.
- `starting` sub module for useful starting positions representations.
- `Piece` color and side value arrays.

## [0.2.0] - 2024-08-12

### Chess module

#### Added

- `Piece` max allowed of each piece.

#### Fixed

- `PieceList` copy by reference.
- `PieceList.assertValid` method using `false` instead of `undefined`.

#### Changed

- **BREAKING** `Piece.max` now `.max_board` for clarity.

## [0.1.2] - 2024-08-11

### Added

#### Chess module

- `Placement` board representation.
- `Placement.Packed` board representation.
- `Color` and `Side` enums `opposite` method.
- `Rank` and `File` `char` methods.
- `Piece` and `Piece.Kind` enums `values` and `hard_values` constants.
- `Piece` from `Color` and `Piece.Kind` method.
- `PieceList` board representation.

## [0.1.1] - 2024-08-10

### Added

#### Chess module

- `Color` and `Side` enums.
- `Square`, `Rank`, `File` and `RankFile` enums.
- `Piece` and `Piece.Kind` enums.

## [0.1.0] - 2024-08-06

### Added

- `chess` module featuring a `BitBoard` representation.

[Unreleased]: https://github.com/sonro/zaplum/compare/v0.3.2...HEAD
[0.3.2]: https://github.com/sonro/zaplum/releases/tag/v0.3.2
[0.3.1]: https://github.com/sonro/zaplum/releases/tag/v0.3.1
[0.3.0]: https://github.com/sonro/zaplum/releases/tag/v0.3.0
[0.2.1]: https://github.com/sonro/zaplum/releases/tag/v0.2.1
[0.2.0]: https://github.com/sonro/zaplum/releases/tag/v0.2.0
[0.1.2]: https://github.com/sonro/zaplum/releases/tag/v0.1.2
[0.1.1]: https://github.com/sonro/zaplum/releases/tag/v0.1.1
[0.1.0]: https://github.com/sonro/zaplum/releases/tag/v0.1.0
