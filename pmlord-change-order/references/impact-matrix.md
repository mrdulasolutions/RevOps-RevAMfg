# Impact Matrix

What each type of change affects across the six impact dimensions.

---

## Master Impact Matrix

| Change Type | Cost | Lead Time | Tooling | Quality | Partner | Logistics |
|-------------|------|-----------|---------|---------|---------|-----------|
| **Quantity increase** | Yes (more material + labor, but unit cost may decrease) | Maybe (longer production run) | Maybe (additional cavities for >50% increase) | No (same specs, adjust AQL sample size) | Yes (notify of volume change) | Yes (more weight, possibly different shipping) |
| **Quantity decrease** | Yes (less total, but unit cost may increase due to fixed costs) | No (shorter run, same setup) | No (same tooling) | No (same specs, adjust AQL sample size) | Yes (notify of volume change) | Yes (less weight, may change packaging) |
| **Material change** | Yes (different material cost per unit) | Yes (new material may have different lead time) | Maybe (mold/die compatibility with new material) | Yes (new material certification, different inspection criteria) | Yes (must source new material) | Maybe (different weight, may affect customs HTS code) |
| **Tolerance tightened** | Yes (higher precision = more manufacturing time + inspection) | Maybe (slower machining, more QC time) | Maybe (tool refinement or replacement) | Yes (may require CMM, tighter AQL, additional measurements) | Yes (updated spec, may need capability verification) | No |
| **Tolerance loosened** | Yes (decrease in manufacturing + inspection cost) | Maybe (faster machining) | No | Yes (simplified inspection, update checklist) | Yes (updated spec) | No |
| **Finish change** | Yes (different finishing process cost) | Maybe (different finishing lead time) | No (finishing is post-tooling) | Yes (new surface inspection criteria, may need testing) | Yes (different process required) | No |
| **Design revision** | Yes (engineering review + possible re-work) | Yes (new tooling lead time + production reset) | Yes (almost always requires tool modification or remake) | Yes (full inspection checklist review, new FAI) | Yes (new drawings, possible capability review) | Maybe (if dimensions/weight change) |
| **Delivery date moved earlier** | Maybe (expedite fee, air freight vs sea freight) | Yes (compressed timeline) | No | No | Yes (must accelerate) | Yes (may need air freight) |
| **Delivery date moved later** | No (or slight decrease if allows optimization) | No (more time available) | No | No | Yes (inform of new schedule) | Maybe (can optimize shipping method) |
| **Add operation** | Yes (additional process cost) | Yes (additional process time) | Maybe (if operation requires tooling) | Yes (new inspection points for added operation) | Yes (capability check, updated process) | No |
| **Remove operation** | Yes (cost decrease) | Maybe (time decrease) | No | Yes (remove inspection points, simplify checklist) | Yes (updated process, less work) | No |
| **Packaging change** | Maybe (different packaging cost) | No | No | No | Yes (different packaging requirements) | Yes (different dimensions, may affect containerization) |
| **Shipping method change** | Yes (sea vs air freight cost difference can be large) | Yes (air = faster, sea = slower) | No | No | No (partner ships same way to port) | Yes (complete logistics re-plan) |

---

## Detailed Impact Notes

### Quantity Changes

**Increase < 20%:** Minimal disruption. Same tooling, longer production run. Unit cost may decrease slightly due to better amortization of setup costs. Partner needs to be notified but typically can accommodate.

**Increase 20-50%:** Moderate impact. May need additional raw material order. Check tooling capacity (e.g., if mold has 4 cavities, can it run more cycles?). Lead time extension likely.

**Increase > 50%:** Significant impact. May need additional tooling (more cavities, multiple molds). Raw material may need separate order. Lead time extension almost certain. Treat as a partial re-quote.

**Decrease < 20%:** Minimal impact. Same tooling, shorter run. Unit cost may increase slightly (fixed costs spread over fewer units). Check minimum order quantities with partner.

**Decrease > 50%:** Check if the order is still viable at the reduced volume. Unit cost increase may be significant. Partner may have minimum run requirements.

### Material Changes

**Same material family** (e.g., 6061-T6 to 6061-T651): Minimal impact. Usually compatible with existing tooling. Similar machining parameters. Inspection criteria largely unchanged.

**Different alloy** (e.g., 6061 to 7075): Moderate impact. Different material cost, possibly different machining parameters. Tooling may or may not be compatible. New material certification required.

**Different material class** (e.g., aluminum to steel, plastic to metal): Major impact. Almost certainly requires new tooling. Completely different manufacturing process. Full re-quote recommended.

### Tolerance Changes

**Tightened by one grade** (e.g., +/-0.1mm to +/-0.05mm): Moderate impact. May require slower machining speeds, more inspection points, possibly CMM verification.

**Tightened significantly** (e.g., +/-0.5mm to +/-0.01mm): Major impact. May require grinding, lapping, or EDM. CMM definitely required. Partner capability verification needed.

**Loosened:** Generally favorable. Faster machining, simpler inspection. Cost should decrease.

### Design Revisions

**Minor revision** (non-critical feature change, cosmetic): Moderate impact. Tooling modification may be possible. Partial FAI may suffice.

**Major revision** (critical dimension change, structural): Significant impact. Tooling likely needs remake. Full FAI required. Treat as near-new order from engineering perspective.

**Complete redesign:** Treat as a new order. Full re-quote required.

---

## Quick Reference: Typical Impact Ranges

| Change Scenario | Typical Cost Impact | Typical Time Impact |
|----------------|--------------------|--------------------|
| Quantity +10% | -2% to +5% total | 0 to +3 days |
| Quantity -10% | +2% to +8% unit cost | 0 days |
| Material upgrade (same family) | +5% to +15% | +3 to +7 days |
| Material downgrade | -5% to -15% | +3 to +7 days (sourcing) |
| Tolerance tightened (one grade) | +10% to +25% | +2 to +5 days |
| Finish change (similar type) | +/- 5% to 15% | +2 to +5 days |
| Design revision (minor) | +5% to +20% | +1 to +3 weeks |
| Design revision (major) | +20% to +100% | +3 to +8 weeks |
| Delivery moved 2 weeks earlier | +5% to +30% (expedite) | -2 weeks |
| Add one operation | +10% to +30% | +3 to +7 days |
