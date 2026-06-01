import json
import logging
import urllib.parse

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    """
    Bedrock Asset Processor — Triggered by S3 upload events.
    Logs the name of the uploaded file to CloudWatch.
    """
    try:
        for record in event.get("Records", []):
            bucket = record["s3"]["bucket"]["name"]
            key = urllib.parse.unquote_plus(
                record["s3"]["object"]["key"], encoding="utf-8"
            )
            size = record["s3"]["object"].get("size", 0)

            message = f"Image received: {key}"
            logger.info(message)
            logger.info(f"Bucket: {bucket}, Size: {size} bytes")

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Processing complete"}),
        }

    except Exception as e:
        logger.error(f"Error processing S3 event: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)}),
        }
