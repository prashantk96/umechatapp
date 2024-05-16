class MessageModel {
  MessageModel({
    required this.toId,
    required this.type,
    required this.fromId,
    required this.msg,
    required this.read,
    required this.sent,
  });
  late final String toId;
  late final String fromId;
  late final String msg;
  late final String read;
  late final String sent;
  late final Type type;

  MessageModel.fromJson(Map<String, dynamic> json) {
    toId = json['to_id'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    fromId = json['from_id'].toString();
    msg = json['msg'].toString();
    read = json['read'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['to_id'] = toId;
    _data['from_id'] = fromId;
    _data['msg'] = msg;
    _data['read'] = read;
    _data['sent'] = sent;
    _data['type'] = type.name;
    return _data;
  }
}

enum Type { image, text }
