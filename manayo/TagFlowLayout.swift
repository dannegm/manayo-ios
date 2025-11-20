import SwiftUI

public struct TagFlowLayout: Layout {
    public var spacing: CGFloat = 8
    
    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? .greatestFiniteMagnitude
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        
        return CGSize(width: maxWidth,
                      height: y + rowHeight)
    }
    
    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let maxWidth = bounds.width
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            
            subview.place(
                at: CGPoint(x: bounds.minX + x,
                            y: bounds.minY + y),
                proposal: ProposedViewSize(size)
            )
            
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
    }
}
