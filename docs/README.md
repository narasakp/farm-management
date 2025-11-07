# 📚 Documentation Index

Welcome to the Farm Management System documentation!

## 📋 Table of Contents

### 🔐 RBAC & Permissions
- **[ALL_ROLES_PERMISSIONS_ENHANCED.md](ALL_ROLES_PERMISSIONS_ENHANCED.md)** - Complete RBAC permissions guide for all 8 roles
- **[FARMER_PERMISSIONS_UPDATED.md](FARMER_PERMISSIONS_UPDATED.md)** - Detailed farmer permissions documentation

### 📦 Queue Booking System
- **[README_QUEUE_BOOKING.md](README_QUEUE_BOOKING.md)** - Queue booking system overview
- **[QUEUE_BOOKING_OVERVIEW.md](QUEUE_BOOKING_OVERVIEW.md)** - System architecture and features
- **[QUEUE_BOOKING_MODELS.md](QUEUE_BOOKING_MODELS.md)** - Data models and structures
- **[QUEUE_BOOKING_TECHNICAL.md](QUEUE_BOOKING_TECHNICAL.md)** - Technical implementation details
- **[QUEUE_BOOKING_IMPLEMENTATION.md](QUEUE_BOOKING_IMPLEMENTATION.md)** - Implementation guide
- **[QUEUE_BOOKING_SESSION_LOG.md](QUEUE_BOOKING_SESSION_LOG.md)** - Development session logs

---

## 🔐 RBAC System (Role-Based Access Control)

### Quick Links
- [Main README](../README.md) - Project overview
- [CHANGELOG](../CHANGELOG.md) - Version history
- [Backend Migrations](../backend/migrations/README.md) - Database migration guide

### Overview
The Farm Management System implements a comprehensive RBAC system with:
- **8 Roles** with different permission levels
- **40 Permissions** across 12 resource categories
- **Hierarchical Structure** (4 levels: Admin, Officers, Specialists, Users)

### Roles Summary

| Role | Level | Permissions | Description |
|------|-------|-------------|-------------|
| 👑 **SUPER_ADMIN** | 1 | 40/40 (100%) | System administrator |
| 🏛️ **AMPHOE_OFFICER** | 2 | 18/40 (45%) | District livestock officer |
| 📋 **TAMBON_OFFICER** | 3 | 15/40 (38%) | Sub-district livestock officer |
| 📋 **RESEARCHER** | 3 | 18/40 (45%) | Researcher & academic |
| 📋 **GROUP_LEADER** | 3 | 20/40 (50%) | Farmer group leader |
| 👤 **FARMER** | 4 | 19/40 (48%) | Farmer (Default role) |
| 👤 **TRADER** | 4 | 13/40 (33%) | Livestock trader |
| 👤 **TRANSPORTER** | 4 | 11/40 (28%) | Transport service provider |

### Permission Categories (40 total)

1. **Dashboard** (7 permissions)
   - own, tambon, amphoe, all, market, transport, group

2. **Farms** (3 permissions)
   - crud, read, summary

3. **Livestock** (4 permissions)
   - crud, read, market, summary

4. **Health** (2 permissions)
   - crud, read

5. **Breeding** (2 permissions)
   - crud, read

6. **Feed** (2 permissions)
   - crud, read

7. **Production** (3 permissions)
   - crud, read, summary

8. **Finance** (2 permissions)
   - own, fund

9. **Trading** (2 permissions)
   - crud, read

10. **Transport** (3 permissions)
    - book, read, crud

11. **Groups** (2 permissions)
    - member, crud

12. **Surveys** (2 permissions)
    - crud, read

13. **Research** (1 permission)
    - crud

14. **Reports** (5 permissions)
    - own, tambon, amphoe, all, group

### Recent Updates (Oct 21, 2025)

#### Version 2.1.0 - RBAC Enhancement
- ✅ Enhanced all 7 roles (except SUPER_ADMIN)
- ✅ Added +60 permissions total
- ✅ Average increase: +111% per role
- ✅ Farmer: 12 → 19 permissions (+58%)
- ✅ Group Leader: 7 → 20 permissions (+186%) 🔥
- ✅ Transporter: 4 → 11 permissions (+175%) 🔥

**Key Improvements:**
- Farmers can now manage groups
- Group leaders have full member data access
- Transporters can access market data
- Researchers can conduct surveys
- All roles can join groups for collaboration

---

## 📦 Queue Booking System

### Overview
Market queue booking system for livestock trading.

**Status:** Documentation Complete, Implementation Pending

**Features:**
- Market schedule management
- Queue booking with zones
- QR code verification
- Real-time availability
- Multi-market support

**Documentation:**
- [System Overview](QUEUE_BOOKING_OVERVIEW.md)
- [Data Models](QUEUE_BOOKING_MODELS.md)
- [Technical Details](QUEUE_BOOKING_TECHNICAL.md)

---

## 🚀 Getting Started

### For Developers
1. Read the [Main README](../README.md) for setup instructions
2. Review [RBAC Permissions](ALL_ROLES_PERMISSIONS_ENHANCED.md) to understand access control
3. Check [Migrations README](../backend/migrations/README.md) for database setup
4. See [CHANGELOG](../CHANGELOG.md) for version history

### For Administrators
1. Understand [All Roles Permissions](ALL_ROLES_PERMISSIONS_ENHANCED.md)
2. Review default [Farmer Permissions](FARMER_PERMISSIONS_UPDATED.md)
3. Learn about role hierarchy and permission structure
4. Use RBAC Admin Dashboard to manage users

### For Users
1. Default role: **FARMER** (19 permissions)
2. Can view marketplace, manage own data
3. Can join and create farmer groups
4. Can access trading and transport services

---

## 📖 Additional Resources

### External Links
- [Flutter Documentation](https://docs.flutter.dev/)
- [Node.js Documentation](https://nodejs.org/docs/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [JWT Best Practices](https://jwt.io/introduction)

### Project Links
- [GitHub Repository](https://github.com/narasakp/farm-management)
- [GitHub Pages](https://narasakp.github.io/farm-management/)

---

## 🤝 Contributing

### Documentation Guidelines
- Use clear, concise language
- Include code examples where applicable
- Update this index when adding new docs
- Follow Markdown best practices
- Use emoji for visual hierarchy

### File Naming Convention
- Use SCREAMING_SNAKE_CASE for important docs
- Use lowercase-with-dashes for regular docs
- Include version date in filename if applicable
- Group related docs with common prefix

---

## 📞 Support

For questions or issues:
1. Check relevant documentation first
2. Review [CHANGELOG](../CHANGELOG.md) for recent changes
3. Consult [Main README](../README.md) for setup help
4. Contact project maintainers

---

**Last Updated:** October 21, 2025
**Version:** 2.1.0
**Status:** Production Ready ✅
