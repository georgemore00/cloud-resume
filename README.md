# Recently took down the project due to AWS cost considerations

# Cloud Resume

This repository is my solution for the [The Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/aws/). It showcases my skills in building a cloud-based resume using various AWS technologies. The project includes a diagram illustrating the architecture of the resume.

## Architecture Diagram

![Architecture Diagram](https://github.com/georgemore00/cloud-resume/blob/main/CloudResume.drawio.png)

## Technologies Used

The Cloud Resume Challenge project incorporates the following technologies:

- **Amazon S3**: Hosts the static website.
- **Amazon CloudFront**: Serves the static files using AWS's content delivery network (CDN) and enables HTTPS.
- **AWS Certificate Manager (ACM)**: Used for issuing a public SSL certificate to provide HTTPS connection.
- **Amazon API Gateway**: Hosts the REST API and exposes Lambda functions.
- **AWS Lambda**: Provides serverless compute for the application.
- **Amazon DynamoDB**: Database used to store page visits.
- **Terraform**: Used for provisioning AWS resources using Infrastructure as Code (IaC).
- **GitHub Actions**: CI/CD pipeline for automated deployments.

## Contact

Feel free to reach out to me for any questions or collaborations:

- Email: georgemore00@hotmail.com
- LinkedIn: [George Moré](https://www.linkedin.com/in/george-mor%C3%A9-6516a11a7/)

You are welcome to explore the project and learn more about my journey in completing the Cloud Resume Challenge!
