# QR Code Table Ordering Web App Requirements

## Core Functional Requirements
- Customers scan a static QR code at their table to open an interactive digital menu.
- Menus display real-time menu listings with photos, descriptions, prices, and availability.
- Customers can customize orders and add special instructions.
- Orders are submitted through the web app, linked to a table and session secured by waiter-served PIN.
- Multiple diners per table can order individually but share a collective session and bill.
- Orders route instantly to kitchen/POS for preparation and tracking.
- Payment integration to allow secure in-app payments.

## System Architecture & Scalability
- Backend using microservices, sharded database by restaurant, caching for speed.
- Support 1000 concurrent users per restaurant and 1000 restaurants system-wide.
- Real-time updates using WebSocket or server-sent events for syncing orders.
- API rate limiting and monitoring to maintain performance.

## Offline & Resilience Features
- Staff/admin app operates offline with local caching of menus/orders.
- Changes queue to sync with backend once internet is restored.
- Conflict resolution mechanisms during sync ensure data integrity.
- Internet failover strategies and manual backup procedures.

## Security & Privacy
- Unique waiter-provided PINs per table/session for secure access.
- Sessions isolate order data per visit with expirations.
- TLS encryption and PCI-compliant payment handling.

## User Experience & Convenience
- No app download needed; QR scan opens browser menu.
- Simple, clear UI with optional multi-language support.
- Group orders under one honor/bill, with order visibility for all diners.
- Balance security and simplicity with waiter-served PINs.

## Database Design Highlights
- Tables for Restaurants, Tables, QR_Codes, Sessions, Users, Menu_Categories, Menu_Items, Orders, Order_Items, Payments.
- Sessions table to isolate order contexts and expire sessions.

## Scalability & Real-time
- Distributed scalable backend and database sharding.
- WebSocket-based real-time sync for orders and sessions.
- Caching and indexing for performance.

## Offline Admin App
- Offline-first local data store (SQLite/IndexedDB).
- Sync queue and background sync engine.
- Conflict resolution based on timestamps/versioning.
- Supports seamless operation during internet downtime.

---

This summary covers all aspects—functional, architectural, security, offline, and UX—needed for a robust, scalable QR code table ordering system.
