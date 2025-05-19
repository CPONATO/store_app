import 'package:shop_app/global_variables.dart';
import 'package:shop_app/models/product_review.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/services/manage_http_response.dart';

class ProductReviewController {
  uploadreview({
    required String buyerId,
    required String email,
    required String productId,
    required double rating,
    required String fullName,
    required String review,
    required context,
  }) async {
    try {
      final ProductReview productReview = ProductReview(
        id: '',
        buyerId: buyerId,
        email: email,
        productId: productId,
        rating: rating,
        fullName: fullName,
        review: review,
      );
      http.Response response = await http.post(
        Uri.parse("$uri/api/produc-review"),
        body: productReview.toJson(),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Review Uploaded");
        },
      );
    } catch (e) {
      throw Exception('$e');
    }
  }
}
