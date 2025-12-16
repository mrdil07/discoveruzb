class ApiResponse<T> {
  String? message;
  T? data;
  Status? status;

  ApiResponse.initial(this.message) : status = Status.INITIAL;
  ApiResponse.haveShops(this.data) : status = Status.HAVESHOPS;
  ApiResponse.error(this.message) : status = Status.ERROR;
  ApiResponse.haveNotShops(this.message) : status = Status.HAVENOTSHOPS;
  ApiResponse.loading(this.message) : status = Status.LOADING;
  ApiResponse.completed(this.data) : status = Status.COMPLETED;
  ApiResponse.empty(this.message) : status = Status.EMPTY;

  bool get isLoading => status == Status.LOADING;
  bool get isCompleted => status == Status.COMPLETED;
  bool get isEmpty => status == Status.EMPTY;
  bool get isError => status == Status.ERROR;
}

enum Status { INITIAL, HAVESHOPS, HAVENOTSHOPS, ERROR, LOADING, COMPLETED, EMPTY }
