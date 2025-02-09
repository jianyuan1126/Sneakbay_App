import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../../../../../../models/order_model.dart';
import 'shipping_label.dart';
import 'qr_code_util.dart';

class PDFGenerator {
  final GlobalKey _labelKey = GlobalKey(); // Define a global key

  Future<bool> generateDropOffPdf(BuildContext context, OrderModel order,
      Map<String, dynamic> userAddress, String trackingId) async {
    final pdf = pw.Document();
    final qrImage = await QRCodeGenerator().generateQRCode(order);

    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('${order.orderId}',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Container(
                width: 180,
                height: 180,
                child: pw.Image(pw.MemoryImage(qrImage), fit: pw.BoxFit.contain),
              ),
              pw.SizedBox(height: 10),
              pw.Text('(For internal use only)',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 12, fontStyle: pw.FontStyle.italic)),
              pw.SizedBox(height: 20),
              pw.Text('${order.sku} | ${order.shoeName}',
                  style: pw.TextStyle(font: ttf, fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Text('${order.size} | ${order.condition} | ${order.packaging}',
                  style: pw.TextStyle(font: ttf, fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Ship by',
                      style: pw.TextStyle(font: ttf, fontSize: 16)),
                  pw.Text(
                      '${DateTime.now().add(const Duration(days: 3)).toString().split(' ')[0]}',
                      style: pw.TextStyle(font: ttf, fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GDEX', style: pw.TextStyle(font: ttf, fontSize: 16)),
                  pw.Text('$trackingId',
                      style: pw.TextStyle(font: ttf, fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Spacer(),
              pw.Text('Please include with your item when shipping or dropoff.',
                  style: pw.TextStyle(font: ttf, fontSize: 14)),
              pw.SizedBox(height: 10),
              pw.Text(order.userName,
                  style: pw.TextStyle(
                      font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/drop_off_label.pdf');
    final fileBytes = await pdf.save();

    await file.writeAsBytes(fileBytes);
    print('PDF generated at: ${file.path}');
    print('PDF content length: ${fileBytes.length}');

    if (!await file.exists()) {
      print('Error: PDF file does not exist');
      return false;
    }

    // Send email with PDF attachment
    return await sendEmail(
        file.path,
        'Drop Off Label',
        'Please find attached your drop off label.',
        true,
        userAddress,
        trackingId,
        order.userEmail,
        order);
  }

  Future<bool> generateShippingPdf(BuildContext context, OrderModel order,
      Map<String, dynamic> userAddress, String trackingId) async {
    final pdf = pw.Document();
    final qrImage = await QRCodeGenerator().generateQRCode(order);

    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    // Render the ShippingLabel offscreen and capture it
    Uint8List labelImage = await _renderAndCaptureOffscreenShippingLabel(
        context, order, trackingId);

    // Add shipping label page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Image(pw.MemoryImage(labelImage), fit: pw.BoxFit.contain),
        ),
      ),
    );

    // Add another page for additional information
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('${order.orderId}',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Container(
                width: 180,
                height: 180,
                child: pw.Image(pw.MemoryImage(qrImage), fit: pw.BoxFit.contain),
              ),
              pw.SizedBox(height: 10),
              pw.Text('(For internal use only)',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 12, fontStyle: pw.FontStyle.italic)),
              pw.SizedBox(height: 20),
              pw.Text('${order.sku} | ${order.shoeName}',
                  style: pw.TextStyle(font: ttf, fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Text('${order.size} | ${order.condition} | ${order.packaging}',
                  style: pw.TextStyle(font: ttf, fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Ship by',
                      style: pw.TextStyle(font: ttf, fontSize: 16)),
                  pw.Text(
                      '${DateTime.now().add(const Duration(days: 3)).toString().split(' ')[0]}',
                      style: pw.TextStyle(font: ttf, fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GDEX', style: pw.TextStyle(font: ttf, fontSize: 16)),
                  pw.Text('$trackingId',
                      style: pw.TextStyle(font: ttf, fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Spacer(),
              pw.Text('Please include with your item when shipping or dropoff.',
                  style: pw.TextStyle(font: ttf, fontSize: 14)),
              pw.SizedBox(height: 10),
              pw.Text(order.userName,
                  style: pw.TextStyle(
                      font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/shipping_label.pdf');
    final fileBytes = await pdf.save();

    await file.writeAsBytes(fileBytes);
    print('PDF generated at: ${file.path}');
    print('PDF content length: ${fileBytes.length}');

    if (!await file.exists()) {
      print('Error: PDF file does not exist');
      return false;
    }

    // Send email with PDF attachment
    return await sendEmail(
        file.path,
        'Shipping Label',
        'Please find attached your shipping label.',
        false,
        userAddress,
        trackingId,
        order.userEmail,
        order);
  }

  Future<Uint8List> _renderAndCaptureOffscreenShippingLabel(
      BuildContext context, OrderModel order, String trackingId) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    Completer<Uint8List> completer = Completer<Uint8List>();

    OverlayEntry entry = OverlayEntry(
      builder: (context) => Positioned(
        top: overlay.size.height,
        left: overlay.size.width,
        width: 400, // Set width to desired size
        height: 600, // Set height to desired size
        child: Material(
          child: RepaintBoundary(
            key: _labelKey,
            child: ShippingLabel(order: order, trackingId: trackingId),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(entry);

    await Future.delayed(
        const Duration(milliseconds: 500)); // Wait for rendering

    RenderRepaintBoundary boundary =
        _labelKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    // Ensure the widget is fully painted
    while (boundary.debugNeedsPaint) {
      print("Waiting for boundary to paint...");
      await Future.delayed(const Duration(milliseconds: 5));
    }

    print("Boundary painted. Capturing image...");
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    completer.complete(pngBytes);

    entry.remove();

    return completer.future;
  }

  Future<bool> sendEmail(
      String filePath,
      String subject,
      String body,
      bool isDropOff,
      Map<String, dynamic> userAddress,
      String trackingId,
      String userEmail,
      OrderModel order) async {
    final smtpServer =
        gmail('jianyuanhandsome@gmail.com', 'oxyl cekx vtpu szyn');
    final message = Message()
      ..from = Address('jianyuanhandsome@gmail.com', 'SneakBay')
      ..recipients.add(userEmail)
      ..subject = subject
      ..text = body
      ..html = _generateEmailBody(isDropOff, userAddress, trackingId, order)
      ..attachments.add(FileAttachment(File(filePath)));

    try {
      print('Sending email to $userEmail');
      print('Email subject: $subject');
      print('Email body: $body');
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      return true;
    } catch (e) {
      print('Message not sent. Error: $e');
      print('Exception: ${e.toString()}');
      return false;
    }
  }

  String _generateEmailBody(bool isDropOff, Map<String, dynamic> userAddress,
      String trackingId, OrderModel order) {
    final orderDetails = """
      <p><strong>Order #: ${order.orderId}</strong></p>
      <p><img src="${order.imgAddress}" alt="Shoe Image" width="200" height="100"></p>
      <p><strong>Name:</strong> ${order.shoeName}</p>
      <p><strong>Condition:</strong> ${order.condition}</p>
      <p><strong>Box:</strong> ${order.packaging}</p>
      <p><strong>Size:</strong> ${order.size}</p>
      <p><strong>Price:</strong> \$${order.price.toString()}</p>
      <p><strong>Tracking ID:</strong> $trackingId</p>
    """;

    if (isDropOff) {
      return """
        <p>Thank you for confirming your sale. You're a few steps away from earning \$${order.price.toString()}.</p>
        <p>Please drop off your item within 3 days at SneakBay Store.</p>
        <p>${orderDetails}</p>
        <p>If you have any questions, please contact us.</p>
      """;
    } else {
      return """
        <p>Thank you for confirming your sale. You're a few steps away from earning \$${order.price.toString()}.</p>
        <p>Four Easy Steps:</p>
        <ol>
          <li>Print your prepaid, pre-addressed shipping label and, if applicable, corresponding packing slip.</li>
          <li>Place your item and applicable packing slip into a standard cardboard box. Secure your item by wrapping it in packing paper, plastic or bubble wrap or by placing a piece of cardboard at the top and bottom of the box. Do not ship your item using only its original box.</li>
          <li>Attach the prepaid shipping label to your box.</li>
          <li>Ensure your package is ready for Gdex collection at:</li>
        </ol>
        <p>${userAddress['streetAddress1']}, ${userAddress['streetAddress2'] ?? ''}, ${userAddress['city']}, ${userAddress['state']}, ${userAddress['postalCode']} MY on ${DateTime.now().add(const Duration(days: 1)).toString().split(' ')[0]}</p>
        <p>Your item must be shipped by ${DateTime.now().add(const Duration(days: 3)).toString().split(' ')[0]}.</p>
        <p>${orderDetails}</p>
        <p>If you have any questions, please contact us.</p>
      """;
    }
  }
}
