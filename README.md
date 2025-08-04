# ✅ Flutter Todo App with Supabase

A **production-ready Android task management application** built with Flutter and Supabase, implementing Clean Architecture principles with BLoC pattern for scalable, maintainable, and testable code.

## 🎯 Target Platform
**Android** - Optimized for Android devices and emulators.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK ^3.29.0
- Dart SDK ^3.7.0
- Android device/emulator or Android Studio
- Git

### Installation & Setup

```bash
# Clone the repository
git clone https://github.com/pedrokondx/flutter_task_manager_supabase.git
cd flutter_task_manager_supabase

# Install dependencies
flutter pub get

# Run the application (single command as required)
flutter run
```

The app will automatically launch on your connected Android device or emulator.

## 🏗️ Architecture Overview

This project follows **Clean Architecture** principles with **SOLID** design patterns:

```
lib/
├── core/                 # Shared utilities, DI, validators
│   ├── data/            # Core data sources & DTOs
│   ├── domain/          # Core entities & use cases  
│   ├── di/              # Dependency injection
│   ├── utils/           # Utilities (dialogs, snackbars)
│   └── validators/      # Form validation logic
├── features/            # Feature-based modules
│   ├── auth/           # Authentication (login/register)
│   ├── task/           # Task CRUD operations
│   ├── category/       # Category management
│   └── attachment/     # File upload/management
└── test/               # Unit & integration tests
```

Each feature follows the same structure:
- **Domain**: Entities, repositories interfaces, use cases
- **Data**: Repository implementations, data sources, DTOs
- **Presentation**: BLoC/Cubit, pages, widgets

## 🛠️ Tech Stack

- **Frontend**: Flutter ^3.29, Dart ^3.7
- **Backend**: Supabase (Authentication, PostgreSQL, Storage)
- **State Management**: BLoC/Cubit pattern
- **Architecture**: Clean Architecture + SOLID principles
- **Testing**: Unit tests with mocks/fakes
- **Navigation**: GoRouter

## 📊 Database Schema

### Tables Structure

```sql
-- Users (handled by Supabase Auth)
auth.users (id, email, created_at, ...)

-- Categories Table
CREATE TABLE public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  name TEXT NOT NULL,
  created_at DATE NOT NULL DEFAULT now(),
  updated_at DATE NOT NULL DEFAULT now()
);

-- Tasks Table  
CREATE TABLE public.tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  due_date DATE,
  status TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Attachments Table
CREATE TABLE public.attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  file_url TEXT NOT NULL,
  file_name TEXT NOT NULL DEFAULT '',
  type TEXT NOT NULL,
  created_at DATE NOT NULL DEFAULT now()
);
```

### Unique Constraints
```sql
-- Prevent duplicate category names per user
CREATE UNIQUE INDEX unique_user_category_name 
ON categories (user_id, lower(name));

-- Prevent duplicate task titles per user  
CREATE UNIQUE INDEX unique_user_task_title 
ON tasks (user_id, lower(title));
```

### Row Level Security (RLS)
All tables have RLS enabled to ensure users can only access their own data:
- Users can only see/modify their own tasks, categories, and attachments
- Attachments inherit security through task ownership
- Categories are isolated per user

## ✨ Features

### 🔐 Authentication
- [x] Email/password registration
- [x] Email/password login  
- [x] Secure logout
- [x] Session persistence (stays logged in)
- [x] Form validation with error messages

### 📋 Task Management
- [x] Create tasks (title, description, due date, category, status)
- [x] Edit existing tasks
- [x] Delete tasks with confirmation
- [x] Task status management: **To Do**, **In Progress**, **Done**
- [x] Real-time filtering by title, description, category, status
- [x] Form validation and error handling

### 🏷️ Category Management  
- [x] Dynamic category creation/editing/deletion
- [x] Category assignment to tasks
- [x] Unique category names per user
- [x] Cascade handling (tasks remain when category deleted)

### 📎 Attachment System
- [x] Photo capture via camera
- [x] Video recording via camera  
- [x] Media selection from gallery
- [x] Multiple file uploads per task
- [x] File validation (size limits, mime types)
- [x] Secure file storage with Supabase Storage
- [x] Attachment preview and deletion

### 🎨 User Experience
- [x] Material Design UI
- [x] Loading indicators throughout app
- [x] Error messages and success feedback
- [x] Form validation with user-friendly messages
- [x] Intuitive navigation with proper back handling

## 🧪 Testing

### Run Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Testing Strategy
- **Unit Tests**: Domain logic, use cases, validators
- **BLoC Tests**: State management and business logic
- **Integration Tests**: End-to-end user flows
- **Error Handling**: Edge cases and failure scenarios
- **Mocks/Fakes**: Isolated testing with dependency injection

### Coverage Areas
- ✅ Authentication flows
- ✅ Task CRUD operations  
- ✅ Category management
- ✅ Attachment handling
- ✅ Form validation
- ✅ Error scenarios

## 📱 Usage Examples

### Creating a Task
1. Tap "+" button on task list
2. Fill required fields: title, select status
3. Optionally add: description, due date, category
4. Attach photos/videos if needed
5. Tap "Create Task"

### Managing Categories  
1. Navigate to Categories from button on header
2. Create new categories with unique names
3. Edit/delete existing categories
4. Categories automatically appear in task forms

### Filtering Tasks
- Use search bar for title/description filtering
- Select status dropdown: All, To Do, In Progress, Done  
- Select category dropdown: All categories or specific one
- Filters work in combination

## 🔧 Development

### Code Quality Standards
- **SOLID Principles**: Single responsibility, dependency inversion
- **Clean Architecture**: Clear separation of concerns  
- **BLoC Pattern**: Reactive state management
- **Either Pattern**: Functional error handling
- **Dependency Injection**: Testable, loosely coupled code
