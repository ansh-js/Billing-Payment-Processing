# Literature Review

This concise review uses established, verifiable publications rather than invented citations. It frames a small/medium system whose core is relational correctness, with anomaly detection as a bounded extension.

| Paper | Year | Technology/DB | Main contribution | Advantage | Limitation |
|---|---:|---|---|---|---|
| Gray, *The Transaction Concept* | 1981 | Transaction processing | Formalizes atomic transaction ideas | Foundation for ACID | Predates web-scale systems |
| Bernstein & Newcomer, *Principles of Transaction Processing* | 2009 | Relational/distributed | Concurrency and recovery design | Rigorous operational guidance | Book, not billing-specific experiment |
| Stonebraker, *SQL Databases v. NoSQL Databases* | 2010 | SQL/NoSQL | Compares data models | Explains relational fit for consistency | Early NoSQL landscape |
| Gilbert & Lynch, *Brewer's Conjecture...* | 2002 | Distributed systems | Clarifies CAP constraints | Useful scalability trade-offs | Not a billing implementation |
| Satoshi Nakamoto, *Bitcoin* | 2008 | Distributed ledger | Decentralized payment record | Tamper-evident design | Throughput/privacy trade-offs |
| Bolton & Hand, *Statistical Fraud Detection* | 2002 | Statistical methods | Fraud detection survey | Clear rule/score baseline | Historical scope |
| Ngai et al., *The application of data mining techniques in financial fraud detection* | 2011 | Data mining | Methods taxonomy | Broad technique comparison | Deployment details vary |
| Whitaker et al., *A fraud detection system* | 1999 | Rule-based detection | Practical anomaly detection | Interpretable alerts | Domain/era specific |

Critical analysis: relational databases are the right default where invoice/payment/refund consistency needs multi-row ACID transactions and strong joins. NoSQL can be suitable for flexible event streams or high-volume telemetry, but requires deliberate consistency compensation. A modular monolith keeps this academic/small-team project deployable; bounded services become appropriate when independent scaling and team ownership outweigh distributed transaction complexity. Rule-based flags are transparent and auditable; ML can catch subtler patterns but needs labels, monitoring and explainability. PostgreSQL suits transactions, constraints and analytics; MongoDB fits rapidly evolving document shapes, not this financial source of truth.

References: Gray (1981) ACM; Gilbert & Lynch (2002) SIGACT News; Stonebraker (2010) CACM; Ngai et al. (2011) Decision Support Systems. Verify institution-required citation format before submission.
