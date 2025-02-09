import 'dart:ui' as ui;
import 'dart:async';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../models/order_model.dart';

class QRCodeGenerator {
  Future<Uint8List> generateQRCode(OrderModel order) async {
    final data = """
      Order ID: ${order.orderId}
      User ID: ${order.userId}
      User Name : ${order.userName}
      Email: ${order.userEmail}
      Shoe Name: ${order.shoeName}
      Size: ${order.size}
      SKU: ${order.sku}
      Condition: ${order.condition}
      Packaging: ${order.packaging}
      Price: \$${order.price}
      Status: ${order.status}
      Tracking ID: ${order.trackingId}
    """;

    final qrPainter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: false,
    );

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    const Size size = Size(180, 180);
    qrPainter.paint(canvas, size);

    final ui.Image qrImage = await recorder
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());
    final ByteData? byteData =
        await qrImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
