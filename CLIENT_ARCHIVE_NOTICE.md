# Client Folder Archive Notice

## ✅ Action Taken

Archived legacy `client/` folder → `client_archived/`

## 📋 Reason

The LENTERA project had **two Flutter folders** with potential conflicts:

1. **`client/`** (archived) - Legacy version
   - SDK: `>=3.3.0 <4.0.0`
   - Version: 0.1.0+1
   - Status: Older implementation

2. **`lentera_app/`** (active) - Current development
   - SDK: `^3.9.0` 
   - Version: 1.0.0+1
   - Status: **Active development target**

## 🎯 Impact

- ✅ Prevents package name conflicts
- ✅ Clears path for Dreamflow merge into `lentera_app/`
- ✅ Legacy code preserved in `client_archived/` for reference

## 📁 Current Structure

```
LENTERA/
├── client_archived/        # Legacy Flutter app (archived)
├── lentera_app/           # Active Flutter app (merge target)
├── dreamflow_source/      # Dreamflow AI code (to merge)
└── server/                # FastAPI backend
```

## ⏭️ Next Steps

Ready to merge `dreamflow_source/` → `lentera_app/`
