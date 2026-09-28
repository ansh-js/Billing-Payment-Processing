# Gap Analysis

Existing work separately addresses transaction processing, database model choice, distributed consistency, and fraud detection. Those studies show trade-offs but do not by themselves supply a compact, demonstrably transaction-safe billing implementation that unifies invoice calculation, payment status, refunds, audit events, role security and query-aware reporting.

Existing literature → independently optimized concerns → integration and teaching gap → this project: a PostgreSQL-centered reference system with constraints, procedure-based payment flow, refund trigger, audit history and measurable query plans. It does not claim that billing systems are novel; the contribution is a transparent integrated architecture suitable for small-to-medium-scale learning and evaluation.
