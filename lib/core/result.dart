/// غلاف بسيط لنتائج العمليات (نجاح/فشل) يُستخدم اختياريًا في طبقات
/// الـ Repository/Service لتوحيد التعامل مع الأخطاء عبر التطبيق مستقبلاً.
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(String message) = Failure<T>;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}
