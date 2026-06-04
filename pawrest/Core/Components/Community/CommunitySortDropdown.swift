//
//  CommunitySortDropdown.swift
//  pawrest
//
//  Created by Moon AYoung on 6/3/26.
//

import SwiftUI

struct CommunitySortDropdown: View {
    
    //MARK: - Properties
    
    @Binding var selection: SortMode
    @Binding var isOpen: Bool
    
    //MARK: - Body
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                isOpen = !isOpen
            }
        } label: {
            HStack(spacing: 6) {
                Text(selection.displayName)
                    .typography(.body2R1)
                    .foregroundColor(.gray80)
                
                Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.gray60)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(.gray0)
            .cornerRadius(10, corners: .allCorners)
            .overlay {
                RoundedCorner(radius: 10, corners: .allCorners)
                    .stroke(.gray20, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            if isOpen {
                dropdownMenu
                    .offset(y: 46)
            }
        }
    }
}

//MARK: - Subviews

private extension CommunitySortDropdown {
    
    var dropdownMenu: some View {
        VStack(spacing: 0) {
            ForEach(SortMode.allCases, id: \.self) { mode in
                Button {
                    selection = mode
                    isOpen = false
                } label: {
                    Text(mode.displayName)
                        .typography(.body2R1)
                        .foregroundColor(.gray80)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                
                if mode != SortMode.allCases.last {
                    Rectangle()
                        .fill(.gray10)
                        .frame(height: 1)
                }
            }
        }
        .frame(width: 108)
        .background(.gray0)
        .cornerRadius(10, corners: .allCorners)
        .overlay {
            RoundedCorner(radius: 10, corners: .allCorners)
                .stroke(.gray20, lineWidth: 1)
        }
        .zIndex(1000)
    }
}
