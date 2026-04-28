# Play Arena — Data Dictionary

**Version 2.0 | April 2026**

This document outlines the data models used in the Play Arena application. It provides a detailed view of the entities, their properties, types, relationships, and the Firestore collection layout that backs them.

> **What changed in v2.0**
> - Added the system audit fields (`createdAt`, `updatedAt`, `cancelledAt`) that the Firestore service has always written but were undocumented.
> - Added `bookingId` to `SlotModel` (written by the booking flow when a slot is reserved).
> - Documented the four collections that previously had Dart models but no persistence layer: `matches`, `teams`, `addOns`, top-level `reviews`.
> - Added a new section: **Firestore Collection Layout** (where each model actually lives).
> - Added a new section: **Naming Collisions in Code** (the duplicate `MatchModel`, `MatchStatus`, and `SkillLevel` definitions across files).

---

## Table of Contents

1. [UserModel](#1-usermodel)
2. [VenueModel](#2-venuemodel)
3. [BookingModel](#3-bookingmodel)
   - 3.1 [AddOn (Embedded)](#31-addon-embedded)
   - 3.2 [SplitPaymentModel (Embedded)](#32-splitpaymentmodel-embedded)
4. [SlotModel](#4-slotmodel)
5. [TimeSlotModel](#5-timeslotmodel)
6. [MatchModel (Pickup)](#6-matchmodel-pickup)
7. [MatchRequestModel](#7-matchrequestmodel)
8. [ReviewModel](#8-reviewmodel)
9. [TeamModel](#9-teammodel)
   - 9.1 [TeamMember (Embedded)](#91-teammember-embedded)
10. [TournamentModel](#10-tournamentmodel)
    - 10.1 [Tournament MatchModel (Embedded)](#101-tournament-matchmodel-embedded)
11. [AddOnModel](#11-addonmodel)
12. [Firestore Collection Layout](#12-firestore-collection-layout)
13. [Naming Collisions in Code](#13-naming-collisions-in-code)

---

## 1. UserModel

Represents a user of the application (player, admin, or ground manager).

| Field Name      | Type             | Description                                                            |
| --------------- | ---------------- | ---------------------------------------------------------------------- |
| id              | String           | Unique identifier for the user.                                        |
| name            | String           | Full name of the user.                                                 |
| email           | String           | Email address of the user.                                             |
| phone           | String           | Phone number of the user.                                              |
| avatarUrl       | String?          | Optional URL to the user's profile picture.                            |
| role            | UserRole         | The role of the user (player, admin, groundManager).                   |
| membershipType  | MembershipType   | The user's membership tier (free, silver, gold, platinum).             |
| totalBookings   | int              | Total number of bookings made by the user.                             |
| favoriteVenues  | List\<String\>   | List of venue IDs the user has marked as favorite.                     |
| createdAt       | DateTime         | Timestamp of when the user account was created.                        |
| **updatedAt**   | **DateTime?**    | **Server timestamp set on every profile write.** *(new in v2.0)*       |

**UserRole:** `player, admin, groundManager`
**MembershipType:** `free, silver, gold, platinum`

---

## 2. VenueModel

Represents a sports venue available for booking.

| Field Name        | Type               | Description                                                            |
| ----------------- | ------------------ | ---------------------------------------------------------------------- |
| id                | String             | Unique identifier for the venue.                                       |
| name              | String             | Name of the venue.                                                     |
| description       | String             | Description of the venue and its facilities.                           |
| address           | String             | Street address of the venue.                                           |
| city              | String             | City where the venue is located.                                       |
| latitude          | double             | Geographical latitude.                                                 |
| longitude         | double             | Geographical longitude.                                                |
| imageUrls         | List\<String\>     | List of URLs for images of the venue.                                  |
| sportTypes        | List\<SportType\>  | List of sports available at the venue.                                 |
| amenities         | List\<Amenity\>    | List of amenities provided (e.g., parking, washrooms).                 |
| rating            | double             | Average user rating of the venue.                                      |
| totalReviews      | int                | Total number of user reviews.                                          |
| pricePerHour      | double             | Standard booking price per hour.                                       |
| peakPricePerHour  | double             | Price per hour during peak times.                                      |
| happyHourPrice    | double             | Price per hour during discounted happy hours.                          |
| openTime          | String             | Venue opening time (e.g., '06:00').                                    |
| closeTime         | String             | Venue closing time (e.g., '23:00').                                    |
| isVerified        | bool               | Indicates if the venue has been verified by admins.                    |
| ownerId           | String             | User ID of the ground manager who owns/manages the venue.              |
| contactPhone      | String             | Contact phone number for the venue.                                    |
| availableSlots    | int                | Number of currently available booking slots.                           |
| totalSlots        | int                | Total capacity of booking slots for the venue.                         |
| rules             | String             | Specific rules and regulations of the venue.                           |
| **createdAt**     | **DateTime?**      | **Server timestamp set when the venue was created.** *(new in v2.0)*   |
| **updatedAt**     | **DateTime?**      | **Server timestamp set on every venue write.** *(new in v2.0)*         |

**SportType:** `boxCricket, football, pickleball, badminton, tennis`
**Amenity:** `parking, cctv, shower, drinkingWater, changingRoom, cafeteria, firstAid, wifi, floodlights, scoreboard`

---

## 3. BookingModel

Represents a booking made by a user for a specific venue slot.

| Field Name      | Type                       | Description                                                           |
| --------------- | -------------------------- | --------------------------------------------------------------------- |
| id              | String                     | Unique identifier for the booking.                                    |
| venueId         | String                     | ID of the venue being booked.                                         |
| venueName       | String                     | Name of the venue at the time of booking.                             |
| userId          | String                     | ID of the user who made the booking.                                  |
| userName        | String                     | Name of the user at the time of booking.                              |
| sportType       | SportType                  | The sport specific to this booking.                                   |
| slot            | SlotModel                  | Embedded data containing details of the booked time slot.             |
| addOns          | List\<AddOn\>              | List of additional items/services purchased with the booking.         |
| totalAmount     | double                     | Total cost of the booking including slot and add-ons.                 |
| paymentStatus   | PaymentStatus              | Current status of the payment (pending, completed, etc.).             |
| bookingStatus   | BookingStatus              | Current status of the booking (upcoming, completed, etc.).            |
| qrCode          | String?                    | Optional QR code string for entry verification.                       |
| splitPayment    | List\<SplitPaymentModel\>  | Details of payment splits if the cost is shared among users.          |
| createdAt       | DateTime                   | Timestamp of when the booking was made.                               |
| **updatedAt**   | **DateTime?**              | **Server timestamp set on every write.** *(new in v2.0)*              |
| **cancelledAt** | **DateTime?**              | **Set by the cancel-booking flow when status flips to `cancelled`.** *(new in v2.0)* |

**PaymentStatus:** `pending, completed, failed, refunded`
**BookingStatus:** `upcoming, ongoing, completed, cancelled`

### 3.1 AddOn (Embedded)

| Field Name | Type   | Description                                |
| ---------- | ------ | ------------------------------------------ |
| id         | String | Unique identifier for the add-on.          |
| name       | String | Name of the add-on item (e.g., 'Cricket Bat'). |
| price      | double | Price per unit of the add-on.              |
| quantity   | int    | Quantity of the add-on selected.           |

### 3.2 SplitPaymentModel (Embedded)

| Field Name | Type   | Description                                                    |
| ---------- | ------ | -------------------------------------------------------------- |
| userId     | String | ID of the user sharing the payment.                            |
| userName   | String | Name of the user.                                              |
| amount     | double | Amount this specific user is responsible for.                  |
| isPaid     | bool   | Whether this user has completed their portion of the payment.  |

---

## 4. SlotModel

Represents a specific time block at a venue. Stored in the `venues/{venueId}/slots` subcollection and also embedded inside `BookingModel.slot`.

| Field Name      | Type          | Description                                                              |
| --------------- | ------------- | ------------------------------------------------------------------------ |
| id              | String        | Unique identifier for the slot.                                          |
| venueId         | String        | ID of the venue this slot belongs to.                                    |
| date            | DateTime      | Date of the slot.                                                        |
| startTime       | String        | Start time of the slot.                                                  |
| endTime         | String        | End time of the slot.                                                    |
| duration        | int           | Duration of the slot in minutes.                                         |
| price           | double        | Price for this specific slot block.                                      |
| isAvailable     | bool          | Whether the slot can currently be booked.                                |
| isHappyHour     | bool          | Indicates if this slot falls under happy hour pricing.                   |
| isPeakHour      | bool          | Indicates if this slot falls under peak hour pricing.                    |
| bookedBy        | String?       | User ID of the person who booked the slot, if applicable.                |
| **bookingId**   | **String?**   | **ID of the booking that holds this slot. Set by `markSlotBooked`, cleared by `releaseSlot`.** *(new in v2.0)* |
| **createdAt**   | **DateTime?** | **Server timestamp set when the slot was first generated.** *(new in v2.0)* |
| **updatedAt**   | **DateTime?** | **Server timestamp updated on availability/booking changes.** *(new in v2.0)* |

---

## 5. TimeSlotModel

> **Status note:** This model is defined in code but is **not currently used** by `FirestoreService`. The active slot collection (`venues/{venueId}/slots`) is read/written using `SlotModel`. Treat `TimeSlotModel` as a candidate for an alternative calendar/management view; if no use case materialises, it should be removed.

| Field Name     | Type       | Description                                                  |
| -------------- | ---------- | ------------------------------------------------------------ |
| id             | String     | Unique identifier for the time slot.                         |
| venueId        | String     | ID of the venue this slot belongs to.                        |
| date           | DateTime   | Date of the time slot.                                       |
| startTime      | String     | Start time.                                                  |
| endTime        | String     | End time.                                                    |
| status         | SlotStatus | Current availability status (available, booked, blocked).    |
| slotType       | SlotType   | Type of pricing applied (regular, happyHour, peak).          |
| price          | double     | Price for this slot.                                         |
| bookedByUserId | String?    | User ID who booked the slot.                                 |

**SlotStatus:** `available, booked, blocked`
**SlotType:** `regular, happyHour, peak`

---

## 6. MatchModel (Pickup)

Represents an informal or pickup game hosted by a user at a venue. Backed by the top-level `matches` collection *(persistence added in v2.0)*.

| Field Name         | Type           | Description                                                            |
| ------------------ | -------------- | ---------------------------------------------------------------------- |
| id                 | String         | Unique identifier for the match.                                       |
| createdByUserId    | String         | ID of the user who organized the match.                                |
| createdByUserName  | String         | Name of the organizer.                                                 |
| venueId            | String         | ID of the venue where the match is held.                               |
| venueName          | String         | Name of the venue.                                                     |
| sportType          | SportType      | The sport being played.                                                |
| matchDate          | DateTime       | Date of the match.                                                     |
| startTime          | String         | Start time.                                                            |
| endTime            | String         | End time.                                                              |
| maxPlayers         | int            | Maximum number of players allowed.                                     |
| currentPlayers     | int            | Current number of players who have joined.                             |
| playerIds          | List\<String\> | List of User IDs who have joined the match.                            |
| requiredSkillLevel | SkillLevel     | The desired skill level of participants.                               |
| costPerPlayer      | double         | The calculated cost each player needs to contribute.                   |
| status             | MatchStatus    | Current state of the match (open, full, etc.).                         |
| notes              | String?        | Optional additional instructions or notes from the organizer.          |
| createdAt          | DateTime       | Timestamp of when the match was created.                               |

**MatchStatus (pickup):** `open, full, inProgress, completed, cancelled`
**SkillLevel (pickup):** `beginner, intermediate, advanced, professional`

> See [Naming Collisions in Code](#13-naming-collisions-in-code) — `MatchStatus` and `SkillLevel` are also defined inside other models with different values.

---

## 7. MatchRequestModel

Represents a 'looking for players' post created by a user. Simpler than `MatchModel` and acts as a posting board.

| Field Name    | Type                 | Description                                                          |
| ------------- | -------------------- | -------------------------------------------------------------------- |
| id            | String               | Unique identifier for the request.                                   |
| hostUserId    | String               | ID of the user looking for players.                                  |
| hostName      | String               | Name of the host.                                                    |
| sportType     | SportType            | The sport they want to play.                                         |
| venueId       | String               | Intended venue ID.                                                   |
| venueName     | String               | Intended venue name.                                                 |
| date          | DateTime             | Date of play.                                                        |
| time          | String               | Time of play.                                                        |
| playersNeeded | int                  | Number of additional players required.                               |
| playersJoined | List\<String\>       | List of User IDs who have agreed to join.                            |
| skillLevel    | SkillLevel           | Desired skill level (beginner, intermediate, advanced, any).         |
| description   | String               | Descriptive text indicating what they are organizing.                |
| status        | MatchRequestStatus   | State of the request (open, full, cancelled, completed).             |
| **createdAt** | **DateTime?**        | **Server timestamp set on creation.** *(new in v2.0)*                |
| **updatedAt** | **DateTime?**        | **Server timestamp updated on every write.** *(new in v2.0)*         |

**MatchRequestStatus:** `open, full, cancelled, completed`
**SkillLevel (request):** `beginner, intermediate, advanced, any` *(note: `any` instead of `professional`)*

---

## 8. ReviewModel

Represents a review and rating left by a user for a venue. Persisted in two places (see [Firestore Collection Layout](#12-firestore-collection-layout)).

| Field Name    | Type           | Description                                                  |
| ------------- | -------------- | ------------------------------------------------------------ |
| id            | String         | Unique identifier for the review.                            |
| userId        | String         | ID of the user who wrote the review.                         |
| userName      | String         | Name of the user.                                            |
| userAvatarUrl | String?        | URL to the user's avatar at the time of review.              |
| venueId       | String         | ID of the venue being reviewed.                              |
| rating        | double         | Rating given out of 5.                                       |
| comment       | String         | Text content of the review.                                  |
| imageUrls     | List\<String\> | List of URLs for any photos attached to the review.          |
| createdAt     | DateTime       | Timestamp when the review was submitted.                     |
| helpfulCount  | int            | Number of times other users marked this review as helpful.   |

---

## 9. TeamModel

Represents a formal team of players, used in tournaments. Backed by the top-level `teams` collection *(persistence added in v2.0)*.

| Field Name    | Type                 | Description                                          |
| ------------- | -------------------- | ---------------------------------------------------- |
| id            | String               | Unique identifier for the team.                      |
| name          | String               | Team name.                                           |
| captainId     | String               | User ID of the team captain.                         |
| captainName   | String               | Name of the team captain.                            |
| sportType     | SportType            | The sport this team plays.                           |
| members       | List\<TeamMember\>   | List of members comprising the team.                 |
| matchesPlayed | int                  | Lifetime matches played by the team.                 |
| wins          | int                  | Total wins.                                          |
| losses        | int                  | Total losses.                                        |
| rating        | double               | A calculated skill rating or ELO for the team.       |

### 9.1 TeamMember (Embedded)

| Field Name | Type   | Description                                                          |
| ---------- | ------ | -------------------------------------------------------------------- |
| userId     | String | ID of the user.                                                      |
| name       | String | Name of the user.                                                    |
| role       | String | Role within the team (e.g., 'Captain', 'Vice-Captain', 'Player').    |

---

## 10. TournamentModel

Represents an organized tournament event at a venue.

| Field Name      | Type                  | Description                                                            |
| --------------- | --------------------- | ---------------------------------------------------------------------- |
| id              | String                | Unique identifier for the tournament.                                  |
| name            | String                | Name of the tournament.                                                |
| sportType       | SportType             | The sport being played.                                                |
| venueId         | String                | ID of the hosting venue.                                               |
| venueName       | String                | Name of the hosting venue.                                             |
| format          | TournamentFormat      | Structure of the tournament (knockout, roundRobin, league).            |
| startDate       | DateTime              | Start date and time of the tournament.                                 |
| endDate         | DateTime              | Expected end date and time.                                            |
| entryFee        | double                | Cost for a team to enter.                                              |
| prizePool       | double                | Total prize money to be distributed.                                   |
| maxTeams        | int                   | Maximum number of teams allowed to register.                           |
| registeredTeams | List\<String\>        | List of Team IDs that have successfully registered.                    |
| matches         | List\<MatchModel\>    | Embedded list of tournament matches (see 10.1 — distinct from pickup). |
| status          | TournamentStatus      | Current state of the tournament (upcoming, ongoing, completed).        |
| rules           | String                | Specific rules and regulations for the event.                          |
| **createdAt**   | **DateTime?**         | **Server timestamp set on creation.** *(new in v2.0)*                  |
| **updatedAt**   | **DateTime?**         | **Server timestamp updated on every write.** *(new in v2.0)*           |

**TournamentFormat:** `knockout, roundRobin, league`
**TournamentStatus:** `upcoming, ongoing, completed`

### 10.1 Tournament MatchModel (Embedded)

Distinct from the pickup `MatchModel` in section 6 — only used inside a `TournamentModel`. They share the class name in code (see [Naming Collisions](#13-naming-collisions-in-code)).

| Field Name   | Type        | Description                                                  |
| ------------ | ----------- | ------------------------------------------------------------ |
| id           | String      | Unique round/fixture ID.                                     |
| tournamentId | String      | ID of parent tournament.                                     |
| team1Id      | String      | ID of first team playing.                                    |
| team1Name    | String      | Name of first team.                                          |
| team2Id      | String      | ID of second team playing.                                   |
| team2Name    | String      | Name of second team.                                         |
| team1Score   | int?        | Final score for team 1.                                      |
| team2Score   | int?        | Final score for team 2.                                      |
| winnerId     | String?     | Team ID of the winner, if concluded.                         |
| matchDate    | DateTime    | Date of this specific game.                                  |
| matchTime    | String      | Time of this specific game.                                  |
| status       | MatchStatus | Live status (scheduled, live, completed).                    |
| round        | String      | Descriptor for the round (e.g., 'Quarter-Final', 'Round 1'). |

**MatchStatus (tournament):** `scheduled, live, completed`

---

## 11. AddOnModel

Represents an item or service that can be rented or purchased at a venue alongside a booking. Backed by the top-level `addOns` collection *(persistence added in v2.0)*.

| Field Name  | Type    | Description                                          |
| ----------- | ------- | ---------------------------------------------------- |
| id          | String  | Unique identifier for the add-on item.               |
| name        | String  | Name of the item (e.g., 'Tennis Racket').            |
| price       | double  | Cost to rent/purchase the item.                      |
| description | String? | Details about the item.                              |
| iconUrl     | String? | URL for an image/icon representing the add-on.       |

---

## 12. Firestore Collection Layout

The Play Arena database uses Cloud Firestore. The following table is the authoritative map of where each model lives. *(New in v2.0 — was missing from v1.0.)*

| Path                                  | Backing Model         | Notes                                                       |
| ------------------------------------- | --------------------- | ----------------------------------------------------------- |
| `users/{uid}`                         | `UserModel`           | Document ID equals the Firebase Auth UID.                   |
| `venues/{venueId}`                    | `VenueModel`          | Auto-generated ID; cascades delete to `slots` and `reviews` subcollections. |
| `venues/{venueId}/slots/{slotId}`     | `SlotModel`           | Subcollection. Holds `bookingId` + `bookedBy` when reserved. |
| `venues/{venueId}/reviews/{reviewId}` | `ReviewModel`         | Subcollection. Used by venue detail pages.                  |
| `bookings/{bookingId}`                | `BookingModel`        | Top-level. Indexed by `userId` and `venueId`.               |
| `matches/{matchId}`                   | `MatchModel` (pickup) | Top-level. **Added in v2.0.** Indexed by `status`, `venueId`, `matchDate`. |
| `matchRequests/{requestId}`           | `MatchRequestModel`   | Top-level. Indexed by `status`.                             |
| `teams/{teamId}`                      | `TeamModel`           | Top-level. **Added in v2.0.** Indexed by `name` and `captainId`. |
| `tournaments/{tournamentId}`          | `TournamentModel`     | Top-level. Indexed by `startDate`. Tournament fixtures are embedded in the document. |
| `addOns/{addOnId}`                    | `AddOnModel`          | Top-level catalog. **Added in v2.0.** Indexed by `name`.    |
| `reviews/{reviewId}`                  | `ReviewModel`         | Top-level mirror. **Added in v2.0.** Use for cross-venue queries (e.g., a user's review history). The per-venue subcollection above is still the source for venue detail pages. |

### System fields written by `FirestoreService`

Every create/update path in `lib/data/services/firestore_service.dart` writes the following server-side timestamps. These are present on every document in every collection above unless explicitly noted:

| Field         | Set on                                        | Type (in Firestore) | Type (after `_convertTimestamps`) |
| ------------- | --------------------------------------------- | ------------------- | --------------------------------- |
| `createdAt`   | every `add` / `set`                           | `Timestamp`         | ISO-8601 `String`                 |
| `updatedAt`   | every `add` / `set` / `update`                | `Timestamp`         | ISO-8601 `String`                 |
| `cancelledAt` | bookings only, on `cancelBooking`             | `Timestamp`         | ISO-8601 `String`                 |
| `bookingId`   | slots only, on `markSlotBooked` (cleared on `releaseSlot`) | `String`  | `String`                          |

> `FirestoreService._convertTimestamps` recursively converts Firestore `Timestamp` values to ISO-8601 strings before they reach `fromJson` factories.

---

## 13. Naming Collisions in Code

The same identifier is declared in more than one Dart file with different shapes. Importing two of them in the same file causes a name clash and requires an import alias.

| Identifier      | File 1                                                         | File 2                                                                  | Difference                                                                                  |
| --------------- | -------------------------------------------------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| `MatchModel`    | `lib/data/models/match_model.dart` (pickup)                    | `lib/data/models/tournament_model.dart` (tournament fixture, embedded)  | Completely different field sets; section 6 vs. section 10.1 in this document.               |
| `MatchStatus`   | `lib/data/models/match_model.dart`: `open, full, inProgress, completed, cancelled` | `lib/data/models/tournament_model.dart`: `scheduled, live, completed` | Pickup lifecycle vs. tournament fixture lifecycle.                                          |
| `SkillLevel`    | `lib/data/models/match_model.dart`: `beginner, intermediate, advanced, professional` | `lib/data/models/match_request_model.dart`: `beginner, intermediate, advanced, any` | Pickup matches require a specific level; match requests allow `any`.                        |

**Recommended remediation** (not yet applied — flag this with the team):

- Rename the tournament-internal class to `TournamentMatchModel` and the tournament-internal enum to `TournamentMatchStatus`.
- Rename the request-side enum to `RequestSkillLevel` (or merge the two into one enum that includes both `professional` and `any`).
- Decide whether `TimeSlotModel` should replace `SlotModel`, be wired into Firestore as its own collection, or be deleted.

---

*End of document.*
