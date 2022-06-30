class FAQListModel {
  bool? success;
  List<FAQListData>? data;

  FAQListModel({this.success, this.data});

  FAQListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new FAQListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FAQListData {
  int? id;
  String? question;
  String? type;
  String? answer;
  String? createdAt;
  String? updatedAt;

  FAQListData(
      {this.id,
      this.question,
      this.type,
      this.answer,
      this.createdAt,
      this.updatedAt});

  FAQListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'].toString();
    type = json['type'];
    answer = json['answer'].toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['question'] = this.question;
    data['type'] = this.type;
    data['answer'] = this.answer;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
