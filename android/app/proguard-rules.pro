# Add project specific ProGuard rules here.

# WorkManager (kéo vào bởi google_mobile_ads) dùng Room 2.2.5, rule đi kèm chỉ giữ tên class.
# R8 full mode (mặc định từ AGP 9) sẽ xoá constructor của WorkDatabase_Impl → crash lúc mở app
# ("Failed to create an instance of androidx.work.impl.WorkDatabase").
-keep class * extends androidx.room.RoomDatabase {
    <init>();
}
