# Hệ thống Admin Quản lý Điểm danh & Nhân sự

Thiết kế giao diện (UI/UX) và luồng xử lý frontend cho hệ thống Admin, kết nối với AppDiemDanh API. Đảm bảo xử lý Token sau khi đăng nhập và tích hợp đầy đủ các module theo yêu cầu.

## User Review Required

> [!IMPORTANT]
> - Xác nhận lại cấu trúc phân trang của API Employee (hiện tại `ApiClient` đang dùng tham số `page`, cần thêm `pageSize` nếu backend hỗ trợ).
> - Mặc định `standardWorkDays` là 26 ngày cho module Bảng lương.
> - Cần file ảnh icon hoặc logo nếu muốn thay thế icon Lucide mặc định.

## Proposed Changes

### [Core & Repository Layer]

#### [MODIFY] [api_client.dart](file:///C:/Users/TUF/AndroidStudioProjects/Appdiemdanh/lib/core/api_client.dart)
- Cập nhật thêm các method API còn thiếu: `updateEmployee`, `registerFace`, `getBranches`, `getMonthlyPayrollSummary`.
- Cải thiện interceptor để xử lý lỗi 401 (Token hết hạn) bằng cách đăng xuất người dùng.

#### [MODIFY] [employee_repository.dart](file:///C:/Users/TUF/AndroidStudioProjects/Appdiemdanh/lib/repositories/employee_repository.dart)
- Thêm method `updateEmployee`.

#### [NEW] [branch_repository.dart](file:///C:/Users/TUF/AndroidStudioProjects/Appdiemdanh/lib/repositories/branch_repository.dart)
- Lấy danh sách chi nhánh phục vụ bộ lọc.

---

### [Controller Layer]

#### [MODIFY] [employee_controller.dart](file:///C:/Users/TUF/AndroidStudioProjects/Appdiemdanh/lib/controllers/employee_controller.dart)
- Thêm state cho `branchId` filter và pagination.
- Thêm logic `updateEmployee`, `toggleStatus`, `resetPassword`.

#### [NEW] [admin_dashboard_controller.dart](file:///C:/Users/TUF/AndroidStudioProjects/Appdiemdanh/lib/controllers/admin_dashboard_controller.dart)
- Quản lý trạng thái Thống kê (Dashboard) và danh sách Check-in trực tiếp.

#### [MODIFY] [payroll_controller.dart](file:///C:/Users/TUF/AndroidStudioProjects/Appdiemdanh/lib/controllers/payroll_controller.dart)
- Cập nhật logic lấy Bảng tổng hợp lương tháng.

---

### [UI / UX Layer]

#### [MODIFY] [admin_dashboard.dart](file:///C:/Users/TUF/AndroidStudioProjects/Appdiemdanh/lib/ui/home/admin_dashboard.dart)
- Thiết kế lại Card chỉ số chuyên nghiệp hơn.
- Thêm bộ lọc Chi nhánh (Dropdown).
- Thêm Bảng danh sách trực tiếp trạng thái check-in.

#### [MODIFY] [employee_list_screen.dart](file:///C:/Users/TUF/AndroidStudioProjects/Appdiemdanh/lib/ui/home/management/employee_list_screen.dart)
- Thêm thanh tìm kiếm và bộ lọc chi nhánh.
- Cải tiến item list: Badge trạng thái, các nút chức năng (Edit, Toggle, Unbind, Reset Pass).
- Form/Modal Create/Update Nhân viên đầy đủ các trường.

#### [NEW] [network_config_screen.dart](file:///C:/Users/TUF/AndroidStudioProjects/Appdiemdanh/lib/ui/home/management/network_config_screen.dart)
- Cấu hình Wi-Fi và IP Tĩnh cho chi nhánh.

#### [NEW] [face_registration_screen.dart](file:///C:/Users/TUF/AndroidStudioProjects/Appdiemdanh/lib/ui/home/management/face_registration_screen.dart)
- Màn hình đăng ký Face Vector cho nhân viên (chụp ảnh/chọn ảnh).

#### [MODIFY] [leave_approval_screen.dart](file:///C:/Users/TUF/AndroidStudioProjects/Appdiemdanh/lib/ui/home/management/leave_approval_screen.dart)
- Danh sách đơn nghỉ với nút Duyệt/Từ chối (kèm lý do).

#### [NEW] [payroll_summary_screen.dart](file:///C:/Users/TUF/AndroidStudioProjects/Appdiemdanh/lib/ui/home/management/payroll_summary_screen.dart)
- Bảng tổng hợp lương tháng.

#### [NEW] [attendance_report_screen.dart](file:///C:/Users/TUF/AndroidStudioProjects/Appdiemdanh/lib/ui/home/management/attendance_report_screen.dart)
- Giao diện xuất báo cáo điểm danh tháng.

## Verification Plan

### Automated Tests
- Kiểm tra logic gán Token trong interceptor của `ApiClient`.
- Unit test cho `EmployeeController` xử lý phân trang.

### Manual Verification
- Chạy ứng dụng trên Emulator, đăng nhập tài khoản Admin.
- Kiểm tra bộ lọc Chi nhánh trên Dashboard có thay đổi số liệu không.
- Thử tạo mới nhân viên và gỡ thiết bị.
- Duyệt đơn nghỉ phép và kiểm tra trạng thái cập nhật.
