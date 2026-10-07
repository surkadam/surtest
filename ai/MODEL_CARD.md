# MODEL CARD — fraud-detection-classifier

## Model details
- **Model name:** fraud-detection-classifier
- **Version:** 1.2.0
- **Owner:** surkadam@qualys.com (team: cs-demo)
- **Framework:** scikit-learn

## Intended use
Demonstration of AI compliance scanning in the qscanner-demo repository.
Classifies sample transactions. Not for production use.

## Capabilities
- Binary classification of synthetic transactions
- Confidence scoring per prediction

## Limitations
- Trained on synthetic data only; not validated against production traffic
- English-language transaction descriptions only

## Training data
- 50k synthetic transactions, no PII, generated for demo purposes
- Dataset version: 2026.09

## Evaluation
- Accuracy 0.91 / Precision 0.88 / Recall 0.84
- Bias assessment completed 2026-08-15 (demographic parity method)

## Human oversight
- All high-risk actions require human approval before execution

## Security
- Data encrypted at rest and in transit
- Audit logging enabled
