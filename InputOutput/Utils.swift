import SwiftUI

func ??<T>(binding: Binding<T?>, fallback: T) -> Binding<T> where T : Equatable {
  return Binding(get: {
    binding.wrappedValue ?? fallback
  }, set: {
    if ($0 == fallback) {
      binding.wrappedValue = nil
    } else {
      binding.wrappedValue = $0
    }
  })
}
