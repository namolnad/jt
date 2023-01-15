indirect enum Transform: Equatable {
    case identity
    case array(Transform)
    case object([KeyValue])

    struct KeyValue: Equatable {
        let key: String
        let transform: Transform
    }
}
