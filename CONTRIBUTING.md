# Contributing to AWS Media Streaming Terraform Module

Thank you for your interest in contributing to this project! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)
- [Documentation](#documentation)
- [Release Process](#release-process)

## Code of Conduct

This project adheres to a code of conduct that we expect all contributors to follow. Please be respectful and constructive in all interactions.

## Getting Started

### Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate permissions
- Git
- Basic understanding of AWS media services
- Familiarity with Terraform module development

### Development Environment

1. **Fork and Clone**
   ```bash
   git clone https://github.com/your-username/tfm-aws-mediastream.git
   cd tfm-aws-mediastream
   ```

2. **Set up AWS Credentials**
   ```bash
   aws configure
   # or use environment variables
   export AWS_ACCESS_KEY_ID=your-access-key
   export AWS_SECRET_ACCESS_KEY=your-secret-key
   export AWS_DEFAULT_REGION=us-east-1
   ```

3. **Install Development Tools**
   ```bash
   # Install terraform-docs for documentation generation
   brew install terraform-docs  # macOS
   # or download from https://github.com/terraform-docs/terraform-docs

   # Install tflint for linting
   brew install tflint  # macOS
   # or download from https://github.com/terraform-linters/tflint

   # Install checkov for security scanning
   pip install checkov
   ```

## Development Setup

### Local Testing

1. **Create a test environment**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with test values
   ```

2. **Initialize and validate**
   ```bash
   terraform init
   terraform validate
   terraform fmt -check
   ```

3. **Run linting**
   ```bash
   tflint
   checkov -d .
   ```

### Module Structure

```
tfm-aws-mediastream/
├── main.tf                 # Main module configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── versions.tf             # Provider version constraints
├── modules/
│   ├── video-processing/   # Video processing submodule
│   └── live-streaming/     # Live streaming submodule
├── examples/               # Usage examples
│   ├── basic-streaming/
│   ├── video-processing-only/
│   ├── live-streaming-only/
│   └── complete/
└── docs/                   # Additional documentation
```

## Contributing Guidelines

### Types of Contributions

We welcome the following types of contributions:

1. **Bug Fixes**: Fix issues in existing functionality
2. **Feature Enhancements**: Add new features or improve existing ones
3. **Documentation**: Improve or add documentation
4. **Examples**: Add new usage examples
5. **Testing**: Improve test coverage
6. **Performance**: Optimize resource usage or costs

### Coding Standards

#### Terraform Best Practices

1. **Naming Conventions**
   - Use snake_case for resource names and variables
   - Use descriptive names that indicate purpose
   - Prefix resources with project identifier

2. **Resource Organization**
   - Group related resources together
   - Use consistent ordering (data sources, locals, resources)
   - Add comments for complex configurations

3. **Variable Validation**
   - Add validation rules for critical variables
   - Provide clear error messages
   - Use appropriate variable types

4. **Documentation**
   - Document all variables and outputs
   - Include examples in descriptions
   - Keep README files up to date

#### Code Style

```hcl
# Good: Clear, descriptive naming
resource "aws_s3_bucket" "source_content" {
  bucket = "${var.project_name}-source-content-${random_id.bucket_suffix.hex}"
  
  tags = merge(local.common_tags, {
    Name    = "${var.project_name}-source-content"
    Purpose = "Source media content storage"
  })
}

# Good: Variable validation
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}
```

### Security Considerations

1. **No Hardcoded Secrets**: Never commit secrets or credentials
2. **Least Privilege**: IAM policies should follow least privilege principle
3. **Encryption**: Enable encryption by default where possible
4. **Validation**: Validate all user inputs
5. **Documentation**: Document security implications

## Pull Request Process

### Before Submitting

1. **Test Your Changes**
   ```bash
   # Validate syntax
   terraform validate
   
   # Format code
   terraform fmt
   
   # Run linting
   tflint
   checkov -d .
   
   # Test deployment (if possible)
   terraform plan
   ```

2. **Update Documentation**
   ```bash
   # Generate documentation
   terraform-docs markdown table --output-file README.md .
   ```

3. **Add Tests** (if applicable)
   - Unit tests for complex logic
   - Integration tests for new features
   - Example configurations

### Pull Request Template

When submitting a PR, please include:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Other (please describe)

## Testing
- [ ] Terraform validate passes
- [ ] Terraform fmt passes
- [ ] Linting passes
- [ ] Manual testing completed
- [ ] Examples updated

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or clearly documented)
```

### Review Process

1. **Automated Checks**: All PRs must pass automated checks
2. **Peer Review**: At least one maintainer review required
3. **Testing**: Changes must be tested in a real environment
4. **Documentation**: Documentation must be updated for user-facing changes

## Testing

### Manual Testing

1. **Basic Functionality**
   ```bash
   # Test basic deployment
   cd examples/basic-streaming
   terraform init && terraform plan
   ```

2. **Feature-Specific Testing**
   ```bash
   # Test video processing only
   cd examples/video-processing-only
   terraform init && terraform plan
   
   # Test live streaming only
   cd examples/live-streaming-only
   terraform init && terraform plan
   ```

3. **Complete Integration**
   ```bash
   # Test full deployment
   cd examples/complete
   terraform init && terraform plan
   ```

### Automated Testing

We use GitHub Actions for automated testing:

```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - name: Terraform Format
        run: terraform fmt -check
      - name: Terraform Validate
        run: terraform validate
      - name: TFLint
        run: tflint
```

## Documentation

### Documentation Standards

1. **README Files**: Each module and example should have a README
2. **Variable Documentation**: All variables must be documented
3. **Output Documentation**: All outputs must be documented
4. **Examples**: Include practical examples for all features
5. **Architecture Diagrams**: Visual representations where helpful

### Generating Documentation

```bash
# Generate module documentation
terraform-docs markdown table --output-file README.md .

# Generate example documentation
cd examples/basic-streaming
terraform-docs markdown table --output-file README.md .
```

## Release Process

### Versioning

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist

1. **Update CHANGELOG.md**
2. **Update version in documentation**
3. **Test all examples**
4. **Create GitHub release**
5. **Update registry (if applicable)**

## Getting Help

### Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Media Services Documentation](https://docs.aws.amazon.com/media-services/)

### Communication

- **Issues**: Use GitHub issues for bug reports and feature requests
- **Discussions**: Use GitHub discussions for questions and ideas
- **Security**: Report security issues privately

## Recognition

Contributors will be recognized in:
- CHANGELOG.md
- GitHub contributors list
- Release notes (for significant contributions)

Thank you for contributing to make this module better for everyone!
